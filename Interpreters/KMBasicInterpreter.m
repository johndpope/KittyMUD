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
	KMGetStateFromCoordinator(state);
	[state processState:coordinator];
	KMGetStateFromCoordinator(newState);
	if(workflow) {
		if(newState == state)
			return;
		[workflow advanceWorkflowForCoordinator:coordinator];
		if(![[workflow currentStep] nextStep]) {
			[coordinator setValue:nil forKeyPath:@"properties.current-workflow"];
		}
	}
	KMGetInterpreterForState(newState,interpreter);
	if(!interpreter)
		interpreter = [[KMBasicInterpreter alloc] init];
	KMSetInterpreterForCoordinatorTo(interpreter);
	[coordinator setFlag:@"message-direct"];
	if(![coordinator isFlagSet:@"no-message"]) {
		[newState softRebootMessage:coordinator];
	}
	else
		[coordinator clearFlag:@"no-message"];	
	[coordinator clearFlag:@"message-direct"];
}

@end
