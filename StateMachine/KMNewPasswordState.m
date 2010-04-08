//
//  KMNewPasswordState.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/17/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//

#import "KMNewPasswordState.h"
#import "KMConnectionCoordinator.h"
#import "NSString+KMAdditions.h"
#import "KMConfirmPasswordState.h"
#import "KMNewPasswordState.h"


@implementation KMNewPasswordState

-(void) processState
{
	[coordinator setFlag:@"new-password"];
	[[coordinator getProperties] setObject:[[coordinator getInputBuffer] MD5] forKey:@"password"];
	KMSetStateForCoordinatorTo([KMConfirmPasswordState class]);
}

+(NSString*) getName
{
	return @"NewPassword";
}

-(void) softRebootMessage
{
	KMSoftRebootCheck;
	[coordinator sendMessageToBuffer:@"Please enter a password for your account:"];
}

+(NSArray*)requirements
{
	return nil;
}

+(NSString*)menuLine
{
	return @"Change your password";
}

+(int) priority
{
	return 3;
}

@end
