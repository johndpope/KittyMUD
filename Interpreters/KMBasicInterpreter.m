//
//  KMBasicInterpreter.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/17/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as 
// published by the Free Software Foundation; either version 3 of 
// the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
//

#import "KMBasicInterpreter.h"
#import "KMConnectionCoordinator.h"
#import "KMState.h"
#import "KMWorkflow.h"

@implementation KMBasicInterpreter

-(void) interpret:(id)coordinator withOldState:(id)state {
	KMGetStateFromCoordinator(newState);
    usleep(1000);
	KMWorkflow* workflow = [coordinator valueForKeyPath:@"properties.current-workflow"];
    KMWorkflowStep* step = [coordinator valueForKeyPath:@"properties.current-workflow-step"];
	if(newState != state) {
		if(workflow) {
			if([workflow getStepForState:newState]) {
				[workflow setWorkflowToStep:newState forCoordinator:coordinator];
			} else {
				[workflow advanceWorkflowForCoordinator:coordinator];
                step = [coordinator valueForKeyPath:@"properties.current-workflow-step"];
				if(![step nextStep]) {
					[coordinator setValue:nil forKeyPath:@"properties.current-workflow"];
				}
			}
			newState = [step myState];
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
		[xstate softRebootMessage];
	}
	else
		[coordinator clearFlag:@"no-message"];	
	[coordinator clearFlag:@"message-direct"];
}

-(void) interpret:(id)coordinator
{
	[coordinator clearFlag:@"softreboot-displayed"];
	KMGetStateFromCoordinator(state);
	[state processState];
	[self interpret:coordinator withOldState:state];
}

@end
