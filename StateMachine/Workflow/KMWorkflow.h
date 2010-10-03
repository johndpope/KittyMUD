//
//  KMWorkgroup.h
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

#import <Cocoa/Cocoa.h>
#import "KMWorkflowStep.h"
#import "KMState.h"
#import "KMObject.h"

@interface  KMWorkflow  : KMObject {
	NSMutableDictionary* steps;
	KMWorkflowStep* firstStep;
	NSMutableDictionary* interpretersForStep;
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

-(void) advanceWorkflowForCoordinator:(id)coordinator;

-(void) setWorkflowToStep:(id<KMState>)state forCoordinator:(id)coordinator;

-(KMWorkflowStep*) getStepForState:(id<KMState>)state;

@property (retain,readonly) NSMutableDictionary* steps;
@property (retain) KMWorkflowStep* firstStep;
@end

extern NSString* const KMCreateCharacterWorkflow;
