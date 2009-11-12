//
//  KMAccountNameState.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/15/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMAccountNameState.h"
#import "KMConnectionCoordinator.h"
#import "NSString+KMAdditions.h"
#import "KMConfirmPasswordState.h"
#import "KMNewPasswordState.h"
#import "KMServer.h"


@implementation KMAccountNameState

-(id<KMState>) processState:(id)coordinator 
{
	NSString* fileName = [[NSString stringWithFormat:@"$(SaveDir)/%@.xml", [coordinator getInputBuffer]] replaceAllVariables];
	id<KMState> returnState;
	NSPredicate* accountNameTest = [NSPredicate predicateWithFormat:@"self.properties.name like[cd] %@", [coordinator getInputBuffer]];
	if([[[[[KMServer getDefaultServer] getConnectionPool] connections] filteredArrayUsingPredicate:accountNameTest] count] > 0) {
		[coordinator sendMessageToBuffer:@"Account name already logged in."];
		[self softRebootMessage:coordinator];
		return self;
	}
	[[coordinator getProperties] setObject:[coordinator getInputBuffer] forKey:@"name"];
	if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
		[coordinator loadFromXML:[@"$(SaveDir)" replaceAllVariables]];
		if([coordinator isFlagSet:@"locked"]) {
			[coordinator sendMessage:[@"Your account is locked.  Contact an administrator at $(AdminEmail) to unlock your account." replaceAllVariables]];
			[[[KMServer getDefaultServer] getConnectionPool] removeConnection:coordinator];
			return nil;
		}
		returnState = [[KMConfirmPasswordState alloc] init];
	} else {
		returnState = [[KMNewPasswordState alloc] init];
	}
	return returnState;
}

-(NSString*) getName
{
	return @"AccountName";
}

-(void) softRebootMessage:(id)coordinator
{
	[coordinator sendMessageToBuffer:@"Please enter your account name:"];
}
@end
