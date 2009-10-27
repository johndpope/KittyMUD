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

-(void) debugPrintWorkflow:(id<KMState>)firstState {
	KMWorkflowStep* step = [steps objectForKey:[(id)firstState className]];
	int zstep = 1;
	do {
		NSLog(@"Step #%d: %@", zstep++, [(id)[step myState] className]);
		step = [step nextStep];
	} while (step);
}

+(KMWorkflow*)createWorkflowForSteps:(id<KMState>)firstStep,... {
	va_list steps;
	va_start(steps,firstStep);
	KMWorkflow* wf = [[KMWorkflow alloc] init];
	[wf addStep:firstStep];
	KMWorkflowStep* cstep = [[wf steps] objectForKey:[(id)firstStep className]];
	id<KMState> state;
	while(state = va_arg(steps,id<KMState>)) {
		[wf addStep:state];
		KMWorkflowStep* nstep = [[wf steps] objectForKey:[(id)state className]];
		[cstep setNextStep:nstep];
		cstep = nstep;
	}
	va_end(steps);
	return wf;
}

-(id<KMState>) startWorkflowAtStep:(id<KMState>)state {
	KMWorkflowStep* step = [steps objectForKey:[(id)state className]];
	if(!step)
		return nil;
	currentStep = step;
	return [currentStep myState];
}

-(id<KMState>) advanceWorkflow {
	currentStep = [currentStep nextStep];
	return [currentStep myState];
}

-(void) addStep:(id<KMState>)state {
	if([steps objectForKey:[(id)state className]] != nil)
		return;
	[steps setObject:[[KMWorkflowStep alloc] initWithState:state] forKey:[(id)state className]];
}

-(void) setNextStepFor:(id<KMState>)state toState:(id<KMState>)nextState {
	KMWorkflowStep* step = [steps objectForKey:[(id)state className]];
	if(step)
	{
		KMWorkflowStep* nextstep = [steps objectForKey:[(id)nextState className]];
		if(!nextstep) {
			[self addStep:nextState];
			nextstep = [steps objectForKey:[(id)nextState className]];
		}
		[step setNextStep:nextstep];
	}
}

-(void) insertStep:(id<KMState>)newState before:(id<KMState>)state
{
	KMWorkflowStep* step = [steps objectForKey:[(id)state className]];
	if(!step)
		return;
	for(id<KMState>xstate in [steps allKeys]) {
		KMWorkflowStep* xstep = [steps objectForKey:xstate];
		if([xstep nextStep] == step) {
			KMWorkflowStep* newStep = [steps objectForKey:[(id)newState className]];
			if(!newStep) {
				[self addStep:newState];
				newStep = [steps objectForKey:[(id)newState className]];
			}
			[newStep setNextStep:[xstep nextStep]];
			[xstep setNextStep:newStep];
			return;
		}
	}
}

-(void) insertStep:(id<KMState>)newState after:(id<KMState>)state
{
	KMWorkflowStep* step = [steps objectForKey:[(id)state className]];
	if(!step)
		return;
	KMWorkflowStep* newStep = [steps objectForKey:[(id)newState className]];
	if(!newStep) {
		[self addStep:newState];
		newStep = [steps objectForKey:[(id)newState className]];
	}
	[newStep setNextStep:[step nextStep]];
	[step setNextStep:newStep];
}

-(void) removeStep:(id<KMState>)state
{
	KMWorkflowStep* step = [steps objectForKey:[(id)state className]];
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

-(KMWorkflowStep*) getStepForState:(id<KMState>)state {
	KMWorkflowStep* step = [steps objectForKey:[(id)state className]];
	return step;
}

@synthesize steps;
@synthesize currentStep;
@end
