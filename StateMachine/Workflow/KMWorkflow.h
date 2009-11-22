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
#import "KMObject.h"

@interface  KMWorkflow  : KMObject {
	NSMutableDictionary* steps;
	KMWorkflowStep* currentStep;
	KMWorkflowStep* firstStep;
}

-(void) addStep:(id<KMState>)state;

-(void) setNextStepFor:(id<KMState>)state toState:(id<KMState>)nextState;

-(void) insertStep:(id<KMState>)newState before:(id<KMState>)state;

-(void) insertStep:(id<KMState>)newState after:(id<KMState>)state;

-(void) removeStep:(id<KMState>)state;

+(KMWorkflow*)createWorkflowForSteps:(id<KMState>)firstStep,...;

+(void) setWorkflow:(KMWorkflow*)aWorkflow forName:(NSString*)aString;

+(KMWorkflow*) getWorkflowForName:(NSString*)string;

-(void) startWorkflowAtStep:(id<KMState>)state forCoordinator:(id)coordinator;

-(void) startWorkflowForCoordinator:(id)coordinator;

-(id<KMState>) advanceWorkflow;

-(KMWorkflowStep*) getStepForState:(id<KMState>)state;

@property (retain,readonly) NSMutableDictionary* steps;
@property (retain) KMWorkflowStep* currentStep;
@property (retain) KMWorkflowStep* firstStep;
@end

extern NSString* KMCreateCharacterWorkflow;