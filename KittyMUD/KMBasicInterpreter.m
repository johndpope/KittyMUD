//
//  KMBasicInterpreter.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "KMBasicInterpreter.h"
#import "KMConnectionCoordinator.h"
#import "KMMessageState.h"

@implementation KMBasicInterpreter

-(void) interpret:(id)coordinator
{
	[coordinator setCurrentState:[[coordinator currentState] processState:coordinator]];
	[coordinator setFlag:@"message-direct"];
	if(![coordinator isFlagSet:@"no-message"]) {
		if([[coordinator currentState] conformsToProtocol:@protocol(KMMessageState)]) {
			[(id<KMMessageState>)[coordinator currentState] sendMessageToCoordinator:coordinator];
		}
	}
	else
		[coordinator clearFlag:@"no-message"];	
	[coordinator clearFlag:@"message-direct"];
}

@end
