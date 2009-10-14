//
//  KMAccountNameState.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/15/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMAccountNameState.h"
#import "KMConnectionCoordinator.h"
#import "KittyMudStringExtensions.h"
#import "KMConfirmPasswordState.h"
#import "KMNewPasswordState.h"
#import "KMServer.h"
#import "KMStateMachine.h"

@implementation KMAccountNameState

+(void)initialize {
	[KMStateMachine registerState:[self class]];
}

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
		[coordinator loadFromXML:[@"$(SaveDir)" replaceAllVariables] withState:NO];
		[coordinator sendMessageToBuffer:@"Please enter your password:"];
		returnState = [[KMConfirmPasswordState alloc] init];
	} else {
		[coordinator sendMessageToBuffer:@"Please enter a password for your account:"];
		returnState = [[KMNewPasswordState alloc] init];
	}
	return returnState;
}

+(NSString*) getName
{
	return @"AccountName";
}

-(void) softRebootMessage:(id)coordinator
{
	[coordinator sendMessageToBuffer:@"Please enter your account name:"];
}
@end
