//
//  KMAccountMenuState.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/18/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as 
// published by the Free Software Foundation; either version 3 of 
// the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
//

#import "KMAccountMenuState.h"
#import "KMConnectionCoordinator.h"
#import "KMAccountMenu.h"
#import "KMState.h"
#import <objc/runtime.h>

static NSMutableArray* KMAccountMenuItems;
@implementation KMAccountMenuState

+(void)initialize
{
	KMAccountMenuItems = [[NSMutableArray alloc] init];
	__strong Class* classes;
	int numClasses = objc_getClassList(NULL, 0);
	
	classes = malloc(sizeof(Class) * (NSUInteger)numClasses);
	objc_getClassList(classes, numClasses);
	for(int i = 0; i < numClasses; i++) {
		@try {
			Class c = classes[i];
			if(class_respondsToSelector(c,@selector(className))) {
				if([[c className] hasPrefix:@"RK"])
					continue;
			}
			if(class_respondsToSelector(c,@selector(conformsToProtocol:))) {
				if([c conformsToProtocol:@protocol(KMAccountMenu)]) {
					OCLog(@"kittymud",info,@"Adding %@ to account menu items with priority %d", [c className], [c priority]);
					[KMAccountMenuItems addObject:c];
				}
			}
		}
		@catch (id exc) {
			continue;
		}
	}
}

-(id) initWithCoordinator:(id)coord
{
	self = [super initWithCoordinator:coord];
	if(self) {
		NSMutableArray* myItems = [[NSMutableArray alloc] init];
		for(Class c in KMAccountMenuItems) {
			NSArray* reqs = [c requirements];
			if(reqs != nil) {
				BOOL meetsReqs = YES;
				for(id item in reqs) {
					if([item isKindOfClass:[NSNumber class]]) {
						// we check the coordinators characters to see if they match the minimum level
					} else {
						if(![coordinator isFlagSet:item])
							meetsReqs = NO;
					}
				}
				if(meetsReqs)
					[myItems addObject:c];
			} else
				[myItems addObject:c];
		}
		KMMenuHandler* menu = [[KMMenuHandler alloc] initWithItems:myItems];
		KMSetMenuForCoordinatorTo(menu);
	}
	return self;
}

NSInteger ComparePriority(id,id,void*);
NSInteger ComparePriority(id a, id b, void* __unused c) {
	if([a priority] < [b priority])
		return NSOrderedAscending;
	else if([a priority] > [b priority])
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}

-(void) processState
{
	KMGetMenuFromCoordinator(menu);
	Class menuClass = [menu getSelection:coordinator withSortFunction:ComparePriority];
	if(!menuClass || ![menuClass conformsToProtocol:@protocol(KMState)])
		return;
	
	KMSetStateForCoordinatorTo(menuClass);
}

+(NSString*) getName
{
	return @"AccountMenu";
}

// Because soft reboot under KittyMUD does not discriminate based on the state, we use this so we can remind players what they were doing after a soft reboot+
-(void) softRebootMessage
{
	KMSoftRebootCheck;
	KMGetMenuFromCoordinator(menu);
	if(!menu) {
		[self initWithCoordinator:coordinator];
		KMSLGetMenuFromCoordinator(menu);
	}
	[menu displayMenu:coordinator withSortFunction:ComparePriority];
}

@end
