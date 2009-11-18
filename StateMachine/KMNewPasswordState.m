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

-(id<KMState>) processState:(id)coordinator
{
	[coordinator setFlag:@"new-password"];
	[[coordinator getProperties] setObject:[[coordinator getInputBuffer] MD5] forKey:@"password"];
	return [[KMConfirmPasswordState alloc] init];
}

-(NSString*) getName
{
	return @"NewPassword";
}

-(void) softRebootMessage:(id)coordinator
{
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