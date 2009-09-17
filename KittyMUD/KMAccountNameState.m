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

@implementation KMAccountNameState

-(id<KMState>) processState:(id)coordinator 
{
	KMConnectionCoordinator* coord = (KMConnectionCoordinator*)coordinator;
	NSString* fileName = [[NSString stringWithFormat:@"$(SaveDir)/%@.acct", [coordinator getInputBuffer]] replaceAllVariables];
	NSFileHandle* saveFile = [NSFileHandle fileHandleForReadingAtPath:fileName];
	if (saveFile != nil) {
		//KMConfirmPasswordState* cps = [[KMConfirmPasswordState alloc] init];
		//return cps;
	} else {
		[coordinator setFlag:@"new_password"];
		//KMNewPasswordState* nps = [[KMNewPasswordState alloc] init];
		//return nps;
	}
}

-(NSString*) getName
{
	return @"AccountName";
}

@end
