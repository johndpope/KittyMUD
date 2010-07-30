//
//  KMAccountNameState.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/15/09.
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

#import "KMAccountNameState.h"
#import "KMConnectionCoordinator.h"
#import "NSString+KMAdditions.h"
#import "KMConfirmPasswordState.h"
#import "KMNewPasswordState.h"
#import "KMServer.h"


@implementation KMAccountNameState

-(void) processState
{
	NSString* fileName = [[NSString stringWithFormat:@"$(SaveDir)/%@.xml", [coordinator getInputBuffer]] replaceAllVariables];
	id<KMState> returnState;
	NSPredicate* accountNameTest = [NSPredicate predicateWithFormat:@"self.properties.name like[cd] %@", [coordinator getInputBuffer]];
	if([[[[[KMServer getDefaultServer] getConnectionPool] connections] filteredArrayUsingPredicate:accountNameTest] count] > 0) {
		[coordinator sendMessageToBuffer:@"Account name already logged in."];
		[self softRebootMessage];
		return;
	}
	[[coordinator getProperties] setObject:[coordinator getInputBuffer] forKey:@"name"];
	if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
		[coordinator loadFromXML:[@"$(SaveDir)" replaceAllVariables]];
		if([coordinator isFlagSet:@"locked"]) {
			[coordinator sendMessage:[@"Your account is locked.  Contact an administrator at $(AdminEmail) to unlock your account." replaceAllVariables]];
			[[[KMServer getDefaultServer] getConnectionPool] removeConnection:coordinator];
			return;
		}
		returnState = (id<KMState>)[KMConfirmPasswordState class];
	} else {
		returnState = (id<KMState>)[KMNewPasswordState class];
	}
	KMSetStateForCoordinatorTo(returnState);
}

+(NSString*) getName
{
	return @"AccountName";
}

-(void) softRebootMessage
{
	KMSoftRebootCheck;
	[coordinator sendMessageToBuffer:@"Please enter your account name:"];
}
@end
