//
//  KMBasicInterpreter.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "KMBasicInterpreter.h"
#import "KMConnectionCoordinator.h"

@implementation KMBasicInterpreter

-(void) interpret:(id)coordinator
{
	NSString* input = [coordinator getInputBuffer];
	[coordinator setCurrentState:[[coordinator currentState] processState:coordinator]];
}

@end
