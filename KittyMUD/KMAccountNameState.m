//
//  KMAccountNameState.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/15/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMAccountNameState.h"
#import "KMConnectionCoordinator.h"
#import "KMMudVariablesExtensions.h"
#import "KMConfirmPasswordState.h"
#import "KMNewPasswordState.h"

@implementation KMAccountNameState

-(id<KMState>) processState:(id)coordinator 
{
	NSString* fileName = [[NSString stringWithFormat:@"$(SaveDir)/%@.acct", [coordinator getInputBuffer]] replaceAllVariables];
	if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
		[coordinator sendMessageToBuffer:@"Please enter your password:"];
		return [[KMConfirmPasswordState alloc] init];
	} else {
		[coordinator sendMessageToBuffer:@"Please enter a password for your account:"];
		return [[KMNewPasswordState alloc] init];
	}
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
