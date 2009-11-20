//
//  KMBasicInterpreter.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/17/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//

#import "KMBasicInterpreter.h"
#import "KMConnectionCoordinator.h"
#import "KMState.h"
#import "KMWorkflow.h"

@implementation KMBasicInterpreter

-(void) interpret:(id)coordinator
{
	KMWorkflow* workflow = [coordinator valueForKeyPath:@"properties.current-workflow"];
	id<KMState> newState = [[coordinator currentState] processState:coordinator];
	if(!workflow) {
		[coordinator setCurrentState:newState];
	} else {
		if(newState == [coordinator currentState])
			return;
		OCLog(@"kittymud",debug,@"Current step in workflow: %@", [(id)[coordinator currentState] className]);
		id<KMState> nextStep = [workflow advanceWorkflow];
		OCLog(@"kittymud",debug,@"Advanced workflow, new step in workflow: %@", [(id)[coordinator currentState] className]);
		[coordinator setCurrentState:nextStep];
		KMWorkflowStep* currentStep = [workflow getStepForState:nextStep];
		if(![currentStep nextStep])
			[coordinator setFlag:@"clear-workflow"];
		
	}
	[coordinator setFlag:@"message-direct"];
	if(![coordinator isFlagSet:@"no-message"]) {
		[[coordinator currentState] softRebootMessage:coordinator];
	}
	else
		[coordinator clearFlag:@"no-message"];	
	[coordinator clearFlag:@"message-direct"];
}

@end
