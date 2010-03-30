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

-(void) interpret:(id)coordinator withOldState:(id)state {
	KMGetStateFromCoordinator(newState);
	KMWorkflow* workflow = [coordinator valueForKeyPath:@"properties.current-workflow"];
	if(newState != state) {
		if(workflow) {
			if([workflow getStepForState:newState]) {
				[workflow setWorkflowToStep:newState forCoordinator:coordinator];
			} else {
				[workflow advanceWorkflowForCoordinator:coordinator];
				if(![[workflow currentStep] nextStep]) {
					[coordinator setValue:nil forKeyPath:@"properties.current-workflow"];
				}
			}
			newState = [[workflow currentStep] myState];
			KMSetStateForCoordinatorTo(newState);
		}
		KMGetInterpreterForState(newState,interpreter);
		if(!interpreter)
			interpreter = [[KMBasicInterpreter alloc] init];
		KMSetInterpreterForCoordinatorTo(interpreter);
	}
	[coordinator setFlag:@"message-direct"];
	if(![coordinator isFlagSet:@"no-message"]) {
		KMGetStateFromCoordinator(xstate);
		[xstate softRebootMessage:coordinator];
	}
	else
		[coordinator clearFlag:@"no-message"];	
	[coordinator clearFlag:@"message-direct"];
}

-(void) interpret:(id)coordinator
{
	[coordinator clearFlag:@"softreboot-displayed"];
	KMGetStateFromCoordinator(state);
	[state processState:coordinator];
	[self interpret:coordinator withOldState:state];
}

@end
