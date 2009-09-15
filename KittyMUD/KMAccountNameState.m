//
//  KMAccountNameState.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "KMAccountNameState.h"


@implementation KMAccountNameState

-(id<KMState>) processState:(KMConnectionCoordinator*)coordinator withInput:(NSString*)input
{
	return nil;
}

-(NSString*) getName
{
	return @"AccountName";
}

@end
