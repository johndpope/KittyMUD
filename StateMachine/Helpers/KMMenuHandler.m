//
//  KMMenuHandler.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/5/09.
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
	if([[myItems objectAtIndex:0] respondsToSelector:@selector(keyForInfo)]) {
		[coordinator sendMessageToBuffer:@"Please make your selection (`c1`x - `c%d`x) or type info <selection> for more information:", [myItems count]];
	} else {
		[coordinator sendMessageToBuffer:@"Please make your selection (`c1`x - `c%d`x):", [myItems count]];
	}
}

-(void)displayMenu:(KMConnectionCoordinator*)coordinator withSortFunction:(NSInteger (*)(id, id, void *))sortFunction
{
	[myItems sortUsingFunction:sortFunction context:NULL];
	[self displayMenu:coordinator];
}

-(id)getSelection:(KMConnectionCoordinator *)coordinator withSortFunction:(NSInteger (*)(id, id, void*))sortFunction
{
	if(sortFunction) {
		[myItems sortUsingFunction:sortFunction context:NULL];
	}
	[coordinator setFlag:@"no-message"];
	int sel = [[coordinator getInputBuffer] intValue];
	if(!sel || (sel > [myItems count]) || sel < 1) {
		if(![[coordinator getInputBuffer] hasPrefix:@"info"])
			[coordinator sendMessageToBuffer:@"\n\rInvalid selection.\n\r"];
		else {
			if([[coordinator getInputBuffer] hasPrefix:@"info"]) {
				NSArray* infoMakeup = [[coordinator getInputBuffer] componentsSeparatedByString:@" "];
				if([infoMakeup count] > 1) {
					int selection = [[infoMakeup objectAtIndex:1] intValue];
					if(!selection || (selection > [myItems count]) || selection < 1) {
						[coordinator sendMessageToBuffer:@"\n\rInvalid selection.\n\r"];
					} else {
						id item = [myRealItems objectAtIndex:(selection - 1)];
						if([item respondsToSelector:@selector(keyForInfo)]) {
							[coordinator sendMessageToBuffer:[NSString stringWithFormat:@"\n\r%@\n\r",[item valueForKeyPath:[item keyForInfo]]]];
						} else {
							[coordinator sendMessageToBuffer:@"\n\rNo info available for given selection.\n\r"];
						}
					}
				}
			} else {
				[coordinator sendMessageToBuffer:@"\n\rUsage:  info <num>\n\r"];
			}
		}
		return nil;
	}
	KMSetMenuForCoordinatorTo(nil);
	id selection = [myRealItems objectAtIndex:(sel - 1)];
	if([selection isKindOfClass:[ECSNode class]]) {
		selection = resolveNode(selection);
	}
	[coordinator clearFlag:@"no-message"];
	return selection;
}

-(id)getSelection:(KMConnectionCoordinator*)coordinator
{
	return [self getSelection:coordinator withSortFunction:NULL];
}

@synthesize myItems;
@end
