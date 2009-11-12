//
//  KMAccountMenuState.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/18/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//

#import "KMAccountMenuState.h"
#import "KMConnectionCoordinator.h"
#import "KMAccountMenu.h"
#import "KMState.h"


static NSMutableArray* menuItems;

@implementation KMAccountMenuState

+(void)load
{
	menuItems = [[NSMutableArray alloc] init];
	__strong Class* classes;
	int numClasses = objc_getClassList(NULL, 0);
	
	classes = malloc(sizeof(Class) * numClasses);
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
					NSLog(@"Adding %@ to account menu items with priority %d", [c className], [c priority]);
					[menuItems addObject:c];
				}
			}
		}
		@catch (id exc) {
			continue;
		}
	}
}

-(id) initializeWithCoordinator:(id)coordinator
{
	self = [super init];
	if(self) {
		myItems = [[NSMutableArray alloc] init];
		for(Class c in menuItems) {
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
		menu = [[KMMenuHandler alloc] initializeWithItems:myItems];
	}
	
	return self;
}

NSInteger ComparePriority(id a, id b, void* c) {
	if([a priority] < [b priority])
		return NSOrderedAscending;
	else if([a priority] > [b priority])
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}

-(id<KMState>) processState:(id)coordinator
{
	Class menuClass = [menu getSelection:(coordinator) withSortFunction:ComparePriority];
	if(!menuClass)
		return self;
	
	id<KMState> state;
	if([menuClass respondsToSelector:@selector(initializeWithCoordinator:)])
	   state = [[menuClass alloc] initializeWithCoordinator:coordinator];
	else
	   state = [[menuClass alloc] init];
	return state;
}
	   
-(NSString*) getName
{
	return @"AccountMenu";
}

// Because soft reboot under KittyMUD does not discriminate based on the state, we use this so we can remind players what they were doing after a soft reboot
-(void) softRebootMessage:(id)coordinator
{
	[menu displayMenu:coordinator withSortFunction:ComparePriority];
}

@synthesize myItems;
@synthesize menu;
@end
