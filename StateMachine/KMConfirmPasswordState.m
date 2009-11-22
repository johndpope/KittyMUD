//
//  KMConfirmPasswordState.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/17/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//

#import "KMConfirmPasswordState.h"
#import "KMNewPasswordState.h"
#import "KMConnectionCoordinator.h"
#import "NSString+KMAdditions.h"
#import "KMServer.h"
#import "KMAccountMenuState.h"


@implementation KMConfirmPasswordState

+(void) processState:(id)coordinator
{
	NSString* hash = [[coordinator getInputBuffer] MD5];
	if(![[[coordinator getProperties] objectForKey:@"password"] isEqualToString:hash])
	{
		if([coordinator isFlagSet:@"new-password"])
		{
			[coordinator sendMessageToBuffer:@"Your passwords do not match, please re-enter:"];
			KMSetStateForCoordinatorTo(KMNewPasswordState);
			return;
		}
		id attemptString = [[coordinator getProperties] objectForKey:@"password-attempts"];
		int attempts = 1;
		if(attemptString != nil)
			attempts = [attemptString intValue] + 1;
		[[coordinator getProperties] setObject:[NSString stringWithFormat:@"%d",attempts] forKey:@"password-attempts"];
		if(attempts >= 5) {
			[coordinator sendMessage:[@"Too many failed attempts.  Your account is now locked, you must contact an administrator at $(AdminEmail) to unlock it." replaceAllVariables]];
			[coordinator setFlag:@"locked"];
			[coordinator saveToXML:[@"$(SaveDir)" replaceAllVariables]];
			[[[KMServer getDefaultServer] getConnectionPool] removeConnection:coordinator];
		}
		[coordinator sendMessageToBuffer:[NSString stringWithFormat:@"Invalid password, please re-enter (%d attempts left):",5-attempts]];
		[coordinator setFlag:@"no-message"];
		return;
	}
	[coordinator clearFlag:@"new-password"];
	[[coordinator getProperties] setObject:@"0" forKey:@"password-attempts"];
	KMSetStateForCoordinatorTo(KMAccountMenuState);
}

+(NSString*) getName
{
	return @"ConfirmPassword";
}

+(void) softRebootMessage:(id)coordinator
{
	if([coordinator isFlagSet:@"new-password"])
		[coordinator sendMessageToBuffer:@"Please confirm your password:"];
	else {
		[coordinator sendMessageToBuffer:@"Please enter your password:"];
	}
}

@end
