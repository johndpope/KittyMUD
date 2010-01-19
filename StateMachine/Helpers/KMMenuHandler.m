//
//  KMMenuHandler.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/5/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMMenuHandler.h"
#import <OCMock/OCMock.h>
#import <objc/runtime.h>
#import <ECScript/ECScript.h>

@implementation KMMenuHandler

-(id)initWithItems:(NSArray*)items
{
	return [self initWithItems:items message:@"Please make a choice from the following selections:>"];
}

-(id)initWithItems:(NSArray *)items message:(NSString*)msg
{
	self = [super init];
	if(self) {
		myItems = [[NSMutableArray alloc] initWithArray:items];
		myRealItems = [NSMutableArray arrayWithCapacity:[myItems count]];
		message = [msg copy];
	}
	return self;
}

-(void)displayMenu:(KMConnectionCoordinator*)coordinator
{
	[coordinator sendMessageToBuffer:message];
	for(int i = 1; i <= [myItems count]; i++) {
		id item = [myItems objectAtIndex:(i-1)];
		NSString* menuLine = nil;
		[myRealItems addObject:item];
		if(![item conformsToProtocol:@protocol(KMMenu)])
		{
			if([item isKindOfClass:NSClassFromString(@"ECSString")]) {
				item = [item string];
			}
			if([item isKindOfClass:[NSString class]]) {
				id m = [item copy];
				item = [OCMockObject mockForProtocol:@protocol(KMMenu)];
				NSMutableArray* mParts = [NSMutableArray arrayWithArray:[m componentsSeparatedByString:@" "]];
				[mParts replaceObjectAtIndex:0 withObject:[[mParts objectAtIndex:0] capitalizedString]];
				m = [mParts componentsJoinedByString:@" "];
				[[[item stub] andReturn:m] menuLine];
				[myItems replaceObjectAtIndex:(i-1) withObject:item];
			}
			else {
				OCLog(@"kittymud",info,@"Non-conforming menu item.  Please fix this, otherwise the menu handler breaks.  Terminating loop.  Your user will see a broken menu and will not be able to progress.");
				return;
			}
		}
		menuLine = [item menuLine];
		[coordinator sendMessageToBuffer:@"`#`c[`G%d`c] `w%@`x", i, menuLine];
	}
	[coordinator sendMessageToBuffer:@"`@"];
	[coordinator sendMessageToBuffer:@"Please make your selection (`c1`x - `c%d`x):", [myItems count]];
	
}

-(void)displayMenu:(KMConnectionCoordinator*)coordinator withSortFunction:(NSInteger (*)(id, id, void *))sortFunction
{
	[myItems sortUsingFunction:sortFunction context:NULL];
	[self displayMenu:coordinator];
}

-(id)getSelection:(KMConnectionCoordinator *)coordinator withSortFunction:(NSInteger (*)(id, id, void*))sortFunction
{
	[myItems sortUsingFunction:sortFunction context:NULL];
	id selection = [self getSelection:coordinator];
	if([selection isKindOfClass:[ECSNode class]]) {
		selection = resolveNode(selection);
	}
	return selection;
}

-(id)getSelection:(KMConnectionCoordinator*)coordinator
{
	int selection = [[coordinator getInputBuffer] intValue];
	if(!selection || (selection > [myItems count]) || selection < 0) {
		[coordinator sendMessageToBuffer:@"Invalid selection.\n\r "];
		return nil;
	}
	KMSetMenuForCoordinatorTo(nil);
	id item = [myRealItems objectAtIndex:(selection - 1)];
	return item;
}

@synthesize myItems;
@end
