//
//  KMWorkgroup.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/26/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMWorkflow.h"

@implementation KMWorkflow
-(id) init
{
	self = [super init];
	if(self) {
		steps = [[NSMutableDictionary alloc] init];
	}
	return self;
}

+(KMWorkflow*)createWorkflowForSteps:(id<KMState>)firstStep,... {
	va_list steps;
	va_start(steps,firstStep);
	KMWorkflow* wf = [[KMWorkflow alloc] init];
	[wf addStep:firstStep];
	KMWorkflowStep* cstep = [[wf steps] objectForKey:firstStep];
	id<KMState> state;
	while(state = va_arg(steps,id<KMState>)) {
		[wf addStep:state];
		KMWorkflowStep* nstep = [[wf steps] objectForKey:state];
		[cstep setNextStep:nstep];
		cstep = nstep;
	}
}

-(void) startWorkflowAtStep:(id<KMState>)state {
	KMWorkflowStep* step = [steps objectForKey:state];
	if(!step)
		return;
	currentStep = step;
}

-(id<KMState>) advanceWorkflow {
	currentStep = [currentStep nextStep];
	return [currentStep myState];
}

-(void) addStep:(id<KMState>)state {
	if([steps objectForKey:state] != nil)
		return;
	[steps setObject:[[KMWorkflowStep alloc] initWithState:state] forKey:state];
}

-(void) setNextStepFor:(id<KMState>)state toState:(id<KMState>)nextState {
	KMWorkflowStep* step = [steps objectForKey:state];
	if(step)
	{
		KMWorkflowStep* nextstep = [steps objectForKey:nextState];
		if(!nextstep) {
			[self addStep:nextState];
			nextstep = [steps objectForKey:nextState];
		}
		[step setNextStep:nextstep];
	}
}

-(void) insertStep:(id<KMState>)newState before:(id<KMState>)state
{
	KMWorkflowStep* step = [steps objectForKey:state];
	if(!step)
		return;
	for(id<KMState>xstate in [steps allKeys]) {
		KMWorkflowStep* xstep = [steps objectForKey:xstate];
		if([xstep nextStep] == step) {
			KMWorkflowStep* newStep = [steps objectForKey:newState];
			if(!newStep) {
				[self addStep:newState];
				newStep = [steps objectForKey:newState];
			}
			[newStep setNextStep:[xstep nextStep]];
			[xstep setNextStep:newStep];
			return;
		}
	}
}

-(void) insertStep:(id<KMState>)newState after:(id<KMState>)state
{
	KMWorkflowStep* step = [steps objectForKey:state];
	if(!step)
		return;
	KMWorkflowStep* newStep = [steps objectForKey:newState];
	if(!newStep) {
		[self addStep:newState];
		newStep = [steps objectForKey:newState];
	}
	[newStep setNextStep:[step nextStep]];
	[step setNextStep:newStep];
}

-(void) removeStep:(id<KMState>)state
{
	KMWorkflowStep* step = [steps objectForKey:state];
	if(!step)
		return;
	for(id<KMState>xstate in [steps allKeys]) {
		KMWorkflowStep* xstep = [steps objectForKey:xstate];
		if([xstep nextStep] == step) {
			[xstep setNextStep:[step nextStep]];
			return;
		}
	}
}

@synthesize steps;
@synthesize currentStep;
@end
