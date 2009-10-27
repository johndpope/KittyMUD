//
//  KMWorkgroup.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/26/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMWorkflowStep.h"
#import "KMState.h"

@interface KMWorkflow : NSObject {
	NSMutableDictionary* steps;
	KMWorkflowStep* currentStep;
}

-(id) init;

-(void) addStep:(id<KMState>)state;

-(void) setNextStepFor:(id<KMState>)nextState toState:(id<KMState>)state;

-(void) insertStep:(id<KMState>)newState before:(id<KMState>)state;

-(void) insertStep:(id<KMState>)newState after:(id<KMState>)state;

-(void) removeStep:(id<KMState>)state;

+(KMWorkflow*)createWorkflowForSteps:(id<KMState>)firstStep,...;

-(id<KMState>) startWorkflowAtStep:(id<KMState>)state;

-(id<KMState>) advanceWorkflow;

-(KMWorkflowStep*) getStepForState:(id<KMState>)state;

@property (retain,readonly) NSMutableDictionary* steps;
@property (retain) KMWorkflowStep* currentStep;
@end
