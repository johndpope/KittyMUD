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
NSString* KMCreateCharacterWorkflow = @"KMCreateCharacterWorkflow";
NSMutableDictionary* interpreters;

@implementation KMWorkflow

+(void) initialize {
	interpreters = [NSMutableDictionary dictionary];
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
	KMWorkflowStep* step = [steps objectForKey:[(id)firstState getName]];
	int zstep = 1;
	do {
		OCLog(@"kittymud",debug,@"Step #%d: %@", zstep++, [(id)[step myState] getName]);
		step = [step nextStep];
	} while (step);
}

+(KMWorkflow*)createWorkflowForSteps:(id<KMState>)firstStep,... {
	va_list steps;
	va_start(steps,firstStep);
	KMWorkflow* wf = [[KMWorkflow alloc] init];
	[wf addStep:firstStep];
	[wf setFirstStep:firstStep];
	KMWorkflowStep* cstep = [[wf steps] objectForKey:[(id)firstStep getName]];
	id<KMState> state;
	while(state = va_arg(steps,id<KMState>)) {
		[wf addStep:state];
		KMWorkflowStep* nstep = [[wf steps] objectForKey:[(id)state getName]];
		[cstep setNextStep:nstep];
		cstep = nstep;
	}
	va_end(steps);
	return wf;
}

#define KMWFSS do { \
	KMSetStateForCoordinatorTo([currentStep myState]); \
} while(0)

-(void) startWorkflowAtStep:(id<KMState>)state forCoordinator:(id)coordinator {
	KMWorkflowStep* step = [steps objectForKey:[(id)state getName]];
	if(!step)
		return;
	currentStep = step;
	KMWFSS;
	[coordinator setValue:self forKeyPath:@"properties.current-workflow"];
}

-(void) startWorkflowForCoordinator:(id)coordinator {
	currentStep = [self firstStep];
	KMWFSS;
	[coordinator setValue:self forKeyPath:@"properties.current-workflow"];
}

-(void) advanceWorkflowForCoordinator:(id)coordinator {
	currentStep = [currentStep nextStep];
	if(!currentStep)
		return;
	KMWFSS;
}

-(void) addStep:(id<KMState>)state {
	if([steps objectForKey:[(id)state getName]] != nil)
		return;
	[steps setObject:[[KMWorkflowStep alloc] initWithState:state] forKey:[(id)state getName]];
}

-(void) setNextStepFor:(id<KMState>)state toState:(id<KMState>)nextState {
	KMWorkflowStep* step = [steps objectForKey:[(id)state getName]];
	if(step)
	{
		KMWorkflowStep* nextstep = [steps objectForKey:[(id)nextState getName]];
		if(!nextstep) {
			[self addStep:nextState];
			nextstep = [steps objectForKey:[(id)nextState getName]];
		}
		[step setNextStep:nextstep];
	}
}

-(void) insertStep:(id<KMState>)newState before:(id<KMState>)state
{
	KMWorkflowStep* step = [steps objectForKey:[(id)state getName]];
	if(!step)
		return;
	for(id<KMState>xstate in [steps allKeys]) {
		KMWorkflowStep* xstep = [steps objectForKey:xstate];
		if([xstep nextStep] == step) {
			KMWorkflowStep* newStep = [steps objectForKey:[(id)newState getName]];
			if(!newStep) {
				[self addStep:newState];
				newStep = [steps objectForKey:[(id)newState getName]];
			}
			[newStep setNextStep:[xstep nextStep]];
			[xstep setNextStep:newStep];
			return;
		}
	}
}

-(void) insertStep:(id<KMState>)newState after:(id<KMState>)state
{
	KMWorkflowStep* step = [steps objectForKey:[(id)state getName]];
	if(!step)
		return;
	KMWorkflowStep* newStep = [steps objectForKey:[(id)newState getName]];
	if(!newStep) {
		[self addStep:newState];
		newStep = [steps objectForKey:[(id)newState getName]];
	}
	[newStep setNextStep:[step nextStep]];
	[step setNextStep:newStep];
}

-(void) removeStep:(id<KMState>)state
{
	KMWorkflowStep* step = [steps objectForKey:[(id)state getName]];
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

-(KMWorkflowStep*) getStepForState:(id<KMState>)state {
	KMWorkflowStep* step = [steps objectForKey:[(id)state getName]];
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
