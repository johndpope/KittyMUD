//
//  KMWorkgroup.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/26/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
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
	while(state = va_arg(steps,id<KMState>)) {
		[wf addStep:state];
		KMWorkflowStep* nstep = [[wf steps] objectForKey:[[state class] getName]];
		[cstep setNextStep:nstep];
		cstep = nstep;
	}
	va_end(steps);
	return wf;
}

#define KMWFSS do { \
	KMSetStateForCoordinatorTo([currentStep myState]); \
} while(0)

#define KMWFSRM do { \
	KMGetStateFromCoordinator(state); \
	[state softRebootMessage]; \
} while(0)

-(void) startWorkflowAtStep:(id<KMState>)state forCoordinator:(id)coordinator {
	KMWorkflowStep* step = [steps objectForKey:[[state class] getName]];
	if(!step)
		return;
	currentStep = step;
	KMWFSS;
	KMWFSRM;
	[coordinator setValue:self forKeyPath:@"properties.current-workflow"];
}

-(void) startWorkflowForCoordinator:(id)coordinator {
	currentStep = [self firstStep];
	KMWFSS;
	KMWFSRM;
	[coordinator setValue:self forKeyPath:@"properties.current-workflow"];
}

-(void) advanceWorkflowForCoordinator:(id)coordinator {
	currentStep = [currentStep nextStep];
	if(!currentStep)
		return;
	KMWFSS;
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
	currentStep = step;
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
@synthesize currentStep;
@synthesize firstStep;
@end
