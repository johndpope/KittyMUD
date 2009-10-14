//
//  KMMenuHandler.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/5/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMMenuHandler.h"


@implementation KMMenuHandler

-(id)initializeWithItems:(NSArray*)items
{
	self = [super init];
	if(self)
		myItems = [[NSMutableArray alloc] initWithArray:items];
	return self;
}

-(void)displayMenu:(KMConnectionCoordinator*)coordinator
{
	[coordinator sendMessageToBuffer:@"Please make a choice from the following selections:>"];
	for(int i = 1; i <= [myItems count]; i++) {
		id item = [myItems objectAtIndex:(i-1)];
		if(![item conformsToProtocol:@protocol(KMMenu)])
		{
			NSLog(@"Non-conforming menu item.  Please fix this, otherwise the menu handler breaks.  Terminating loop.  Your user will see a broken menu and not be able to progress.");
			return;
		}
		[coordinator sendMessageToBuffer:[NSString stringWithFormat:@"`#`c[`G%d`c] `w%@`x", i, [item menuLine]]];
	}
	[coordinator sendMessageToBuffer:@"`@"];
	[coordinator sendMessageToBuffer:[NSString stringWithFormat:@"Please make your selection (`c1`x - `c%d`x):", [myItems count]]];
	
}

-(void)displayMenu:(KMConnectionCoordinator*)coordinator withSortFunction:(NSInteger (*)(id, id, void *))sortFunction
{
	[myItems sortUsingFunction:sortFunction context:NULL];
	[self displayMenu:coordinator];
}

-(id)getSelection:(KMConnectionCoordinator *)coordinator withSortFunction:(NSInteger (*)(id, id, void*))sortFunction
{
	[myItems sortUsingFunction:sortFunction context:NULL];
	return [self getSelection:coordinator];
}

-(id)getSelection:(KMConnectionCoordinator*)coordinator
{
	int selection = [[coordinator getInputBuffer] intValue];
	if(!selection || (selection > [myItems count]) || selection < 0) {
		[coordinator sendMessageToBuffer:@"Invalid selection.\n\r "];
		return nil;
	}
	id item = [myItems objectAtIndex:(selection - 1)];
	return item;
}

@end
