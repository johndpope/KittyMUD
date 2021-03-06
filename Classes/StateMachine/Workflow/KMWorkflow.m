//
//  KMWorkgroup.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/26/09.
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

#import "KMWorkflow.h"
#import "KMChooseRaceState.h"
#import "KMStatAllocationState.h"
#import "KMConfirmStatAllocationState.h"
#import "KMChooseClassState.h"
#import "KMPlayingState.h"

static NSMutableDictionary* kwfWorkflows;
NSString* const KMCreateCharacterWorkflow = @"KMCreateCharacterWorkflow";
NSMutableDictionary* interpreters;

@implementation KMWorkflow

+(void) load {
	interpreters = [[NSMutableDictionary alloc] init];
}

+(void) initialize {
	kwfWorkflows = [NSMutableDictionary dictionary];
	KMWorkflow* wf = [self createWorkflowForSteps:[[KMChooseRaceState alloc] init],[[KMStatAllocationState alloc] init], [[KMConfirmStatAllocationState alloc] init], [[KMChooseClassState alloc] init], [[KMPlayingState alloc] init], nil];
	[self setWorkflow:wf forName:KMCreateCharacterWorkflow];
}

-(id) init
{
	self = [super init];
	if(self) {
		steps = [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(void) debugPrintWorkflow:(id<KMState>)firstState {
	KMWorkflowStep* step = [steps objectForKey:[[firstState class] getName]];
	int zstep = 1;
	do {
		OCLog(@"kittymud",debug,@"Step #%d: %@", zstep++, [[[step myState] class] getName]);
		step = [step nextStep];
	} while (step);
}

+(KMWorkflow*)createWorkflowForSteps:(id<KMState>)firstStep,... {
	va_list steps;
	va_start(steps,firstStep);
	KMWorkflow* wf = [[KMWorkflow alloc] init];
	[wf addStep:firstStep];
	[wf setFirstStep:[[wf steps] objectForKey:[[firstStep class] getName]]];
	KMWorkflowStep* cstep = [[wf steps] objectForKey:[[firstStep class] getName]];
	id<KMState> state;
	while((state = va_arg(steps,id<KMState>))) {
		[wf addStep:state];
		KMWorkflowStep* nstep = [[wf steps] objectForKey:[[state class] getName]];
		[cstep setNextStep:nstep];
		cstep = nstep;
	}
	va_end(steps);
	return wf;
}

#define KMWFSS do { \
	KMSetStateForCoordinatorTo([step myState]); \
} while(0)

#define KMWFSRM do { \
	KMGetStateFromCoordinator(state); \
	[state softRebootMessage]; \
} while(0)

-(void) startWorkflowAtStep:(id<KMState>)_state forCoordinator:(id)coordinator {
	KMWorkflowStep* step = [steps objectForKey:[[_state class] getName]];
	if(!step)
		return;
    [coordinator setValue:step forKeyPath:@"properties.current-workflow-step"];
	KMWFSS;
	KMWFSRM;
	[coordinator setValue:self forKeyPath:@"properties.current-workflow"];
}

-(void) startWorkflowForCoordinator:(id)coordinator {
	KMWorkflowStep* step = [self firstStep];
	KMWFSS;
	KMWFSRM;
    [coordinator setValue:step forKeyPath:@"properties.current-workflow-step"];
	[coordinator setValue:self forKeyPath:@"properties.current-workflow"];
}

-(void) advanceWorkflowForCoordinator:(id)coordinator {
    KMWorkflowStep* step = [coordinator valueForKeyPath:@"properties.current-workflow-step"];
	step = [step nextStep];
	if(!step)
		return;
	KMWFSS;
    [coordinator setValue:step forKeyPath:@"properties.current-workflow-step"];
}

-(void) addStep:(id<KMState>)state {
	if([steps objectForKey:[[state class] getName]] != nil)
		return;
	[steps setObject:[[KMWorkflowStep alloc] initWithState:state] forKey:[[state class] getName]];
}

-(void) setNextStepFor:(id<KMState>)state toState:(id<KMState>)nextState {
	KMWorkflowStep* step = [steps objectForKey:[[state class] getName]];
	if(step)
	{
		KMWorkflowStep* nextstep = [steps objectForKey:[[nextState class] getName]];
		if(!nextstep) {
			[self addStep:nextState];
			nextstep = [steps objectForKey:[[nextState class] getName]];
		}
		[step setNextStep:nextstep];
	}
}

-(void) insertStep:(id<KMState>)newState before:(id<KMState>)state
{
	KMWorkflowStep* step = [steps objectForKey:[[state class] getName]];
	if(!step)
		return;
	for(id<KMState>xstate in [steps allKeys]) {
		KMWorkflowStep* xstep = [steps objectForKey:xstate];
		if([xstep nextStep] == step) {
			KMWorkflowStep* newStep = [steps objectForKey:[[newState class] getName]];
			if(!newStep) {
				[self addStep:newState];
				newStep = [steps objectForKey:[[newState class] getName]];
			}
			[newStep setNextStep:[xstep nextStep]];
			[xstep setNextStep:newStep];
			return;
		}
	}
}

-(void) insertStep:(id<KMState>)newState after:(id<KMState>)state
{
	KMWorkflowStep* step = [steps objectForKey:[[state class] getName]];
	if(!step)
		return;
	KMWorkflowStep* newStep = [steps objectForKey:[[newState class] getName]];
	if(!newStep) {
		[self addStep:newState];
		newStep = [steps objectForKey:[[newState class] getName]];
	}
	[newStep setNextStep:[step nextStep]];
	[step setNextStep:newStep];
}

-(void) removeStep:(id<KMState>)state
{
	KMWorkflowStep* step = [steps objectForKey:[[state class] getName]];
	if(!step)
		return;
	for(id<KMState>xstate in [steps allKeys]) {
		KMWorkflowStep* xstep = [steps objectForKey:xstate];
		if([xstep nextStep] == step) {
			[xstep setNextStep:[step nextStep]];
			[steps removeObjectForKey:xstate];
			return;
		}
	}
}

-(void) setWorkflowToStep:(id<KMState>)state forCoordinator:(id)coordinator {
	KMWorkflowStep* step = [steps objectForKey:[[state class] getName]];
	if(!step)
		return;
    [coordinator setValue:step forKeyPath:@"properties.current-workflow-step"];
	KMWFSS;
}

-(KMWorkflowStep*) getStepForState:(id<KMState>)state {
	KMWorkflowStep* step = [steps objectForKey:[[state class] getName]];
	return step;
}

+(void) setWorkflow:(KMWorkflow *)aWorkflow forName:(NSString *)aString {
	[kwfWorkflows setObject:aWorkflow forKey:aString];
}

+(KMWorkflow*) getWorkflowForName:(NSString *)string {
	return [kwfWorkflows objectForKey:string];
}

@synthesize steps;
@synthesize firstStep;
@end
