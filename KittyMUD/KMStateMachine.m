//
//  KMStateMachine.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/13/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMStateMachine.h"

static NSMutableDictionary* states;

@implementation KMStateMachine

+(void)initialize {
	states = [[NSMutableDictionary alloc] init];
}

+(id<KMState>) getState:(NSString*)state
{
	return [states objectForKey:state];
}

+(void) registerState:(id<KMState>)state
{
	[states setObject:state forKey:[state getName]];
}

@end
