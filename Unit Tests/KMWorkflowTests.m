//
//  KMWorkflowTests.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/27/09.
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

#import "KMWorkflowTests.h"
#import "KMWorkflow.h"
#import "KMState.h"
#import <OCMock/OCMock.h>
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

static NSMutableArray* used;
@implementation KMWorkflowTests

-(void) setUp {
	used = [[NSMutableArray alloc] init];
}

-(NSString*)createRandomStateClassName {
	int num = arc4random() % 50; // allows for 50 random class names
	NSString* name = [NSString stringWithFormat:@"KMTState%dTest",num];
	NSPredicate* testPred = [NSPredicate predicateWithFormat:@"self like[cd] %@",name];
	NSArray* isUsed = [used filteredArrayUsingPredicate:testPred];
	if([isUsed count] > 0)
		return [self createRandomStateClassName];
	[used addObject:name];
	return name;
}

-(void) tearDown {
	used = nil;
}

typedef id KMS;

-(KMS)createMockObject {
	KMS state = [OCMockObject mockForProtocol:@protocol(KMState)];
	[[[state stub] andReturn:[self createRandomStateClassName]] getName];
	return state;
}

#define assertThatSteps(n) assertThat([NSNumber numberWithInt:[[[wf steps] allKeys] count]], equalTo([NSNumber numberWithInt:n]))
/**/
-(void) testCreateWorkflow {
	KMS s1, s2, s3, s4, s5, s6;
	s1 = [self createMockObject];
	s2 = [self createMockObject];
	s3 = [self createMockObject];
	s4 = [self createMockObject];
	s5 = [self createMockObject];
	s6 = [self createMockObject];
	KMWorkflow* wf = [KMWorkflow createWorkflowForSteps:s1,s2,s3,s4,s5,s6,nil];
	assertThatSteps(6);
}

-(void) testAddStepToWorkflow
{
	KMS s1, s2;
	s1 = [self createMockObject];
	s2 = [self createMockObject];
	KMWorkflow* wf = [KMWorkflow createWorkflowForSteps:s1,nil];
	assertThatSteps(1);
	[wf addStep:s2];
	assertThatSteps(2);
}

-(void) testInsertStepBefore
{
	KMS s1, s2, s3;
	s1 = [self createMockObject];
	s2 = [self createMockObject];
	s3 = [self createMockObject];
	KMWorkflow* wf = [KMWorkflow createWorkflowForSteps:s1,s2,nil];
	assertThatSteps(2);
	[wf insertStep:s3 before:s2];
	assertThatSteps(3);
	KMWorkflowStep* wfs = [wf getStepForState:s1];
	assertThat([wfs myState], is(equalTo(s1)));
	KMWorkflowStep* wfs2 = [wf getStepForState:s2];
	assertThat([wfs2 myState], is(equalTo(s2)));
	KMWorkflowStep* wfs3 = [wf getStepForState:s3];
	assertThat([wfs3 myState], is(equalTo(s3)));
	assertThat([wfs nextStep], is(equalTo(wfs3)));
	assertThat([wfs3 nextStep], is(equalTo(wfs2)));
}

-(void) testInsertStepAfter
{
	KMS s1, s2, s3;
	s1 = [self createMockObject];
	s2 = [self createMockObject];
	s3 = [self createMockObject];
	KMWorkflow* wf = [KMWorkflow createWorkflowForSteps:s1, s2, nil];
	assertThatSteps(2);
	[wf insertStep:s3 after:s2];
	assertThatSteps(3);
	KMWorkflowStep* wfs2 = [wf getStepForState:s2];
	assertThat([wfs2 myState], is(equalTo(s2)));
	KMWorkflowStep* wfs3 = [wf getStepForState:s3];
	assertThat([wfs3 myState], is(equalTo(s3)));
	assertThat([wfs2 nextStep], is(equalTo(wfs3)));
}

-(void) testRemoveStep
{
	KMS s1, s2;
	s1 = [self createMockObject];
	s2 = [self createMockObject];
	KMWorkflow* wf = [KMWorkflow createWorkflowForSteps:s1,s2,nil];
	assertThatSteps(2);
	[wf removeStep:s2];
	assertThatSteps(1);
}

-(void) testSetStepAfter
{
	KMS s1, s2, s3;
	s1 = [self createMockObject];
	s2 = [self createMockObject];
	s3 = [self createMockObject];
	KMWorkflow* wf = [KMWorkflow createWorkflowForSteps:s1,s2,nil];
	assertThatSteps(2);
	[wf setNextStepFor:s1 toState:s3];
	assertThatSteps(3);
	KMWorkflowStep* wfs1 = [wf getStepForState:s1];
	assertThat([wfs1 myState], is(equalTo(s1)));
	KMWorkflowStep* wfs3 = [wf getStepForState:s3];
	assertThat([wfs3 myState], is(equalTo(s3)));
	assertThat([wfs1 nextStep], is(equalTo(wfs3)));
	is(nilValue([wfs3 nextStep]));
}

-(void) testStartWorkflow
{
	KMS s1, s2;
	s1 = [self createMockObject];
	s2 = [self createMockObject];
	KMWorkflow* wf = [KMWorkflow createWorkflowForSteps:s1,s2,nil];
	assertThatSteps(2);
	KMS s3 = [wf startWorkflowAtStep:s1];
	assertThat(s3, is(equalTo(s1)));
}

-(void) testAdvanceWorkflow
{
	KMS s1, s2;
	s1 = [self createMockObject];
	s2 = [self createMockObject];
	KMWorkflow* wf = [KMWorkflow createWorkflowForSteps:s1,s2,nil];
	assertThatSteps(2);
	KMS s3 = [wf startWorkflowAtStep:s1];
	assertThat(s3, is(equalTo(s1)));
	s3 = [wf advanceWorkflow];
	assertThat(s3, is(equalTo(s2)));
}

-(void) testEndWorkflow
{
	KMS s1, s2;
	s1 = [self createMockObject];
	s2 = [self createMockObject];
	KMWorkflow* wf = [KMWorkflow createWorkflowForSteps:s1,s2,nil];
	assertThatSteps(2);
	KMS s3 = [wf startWorkflowAtStep:s1];
	assertThat(s3, is(equalTo(s1)));
	s3 = [wf advanceWorkflow];
	assertThat(s3, is(equalTo(s2)));
	s3 = [wf advanceWorkflow];
	is(nilValue(s3));
}
*/
@end
