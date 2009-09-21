//
//  KMAccountMenuState.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "KMAccountMenuState.h"
#import "KMConnectionCoordinator.h"
#import "KMAccountMenu.h"
#import "KMMessageState.h"

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
	int selection = [[coordinator getInputBuffer] intValue];
	if(!selection || (selection > [myItems count])) {
		[coordinator sendMessageToBuffer:@"Invalid selection.\n\r "];
		return self;
	}
	[myItems sortUsingFunction:ComparePriority context:NULL];
	Class menuClass = [myItems objectAtIndex:(selection - 1)];
	id<KMState> state;
	if([menuClass respondsToSelector:@selector(initializeWithCoordinator:)])
	   state = [[menuClass alloc] initializeWithCoordinator:coordinator];
	else
	   state = [[menuClass alloc] init];
	if(![state conformsToProtocol:@protocol(KMMessageState)])
		[state softRebootMessage:coordinator];
	return state;
}
	   
-(NSString*) getName
{
	return @"AccountMenu";
}

// Because soft reboot under KittyMUD does not discriminate based on the state, we use this so we can remind players what they were doing after a soft reboot
-(void) softRebootMessage:(id)coordinator
{
	[self sendMessageToCoordinator:coordinator];
}

-(void) sendMessageToCoordinator:(id)coordinator
{
	[coordinator sendMessageToBuffer:@"Please make a choice from the following selections:\n\r "];
	[myItems sortUsingFunction:ComparePriority context:NULL];
	for(int i = 1; i <= [myItems count]; i++) {
		Class item = [myItems objectAtIndex:(i-1)];
		[coordinator sendMessageToBuffer:[NSString stringWithFormat:@"\t\t`c[`G%d`c] `w%@`x", i, [item menuLine]]];
	}
	[coordinator sendMessageToBuffer:@"\n\r"];
	[coordinator sendMessageToBuffer:[NSString stringWithFormat:@"Please make your selection (`c1`x - `c%d`x):", [menuItems count]]];
}
@end
