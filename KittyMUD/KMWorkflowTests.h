//
//  KMWorkflowTests.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/27/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

@interface KMWorkflowTests : SenTestCase {
}

-(void) testCreateWorkflow;

-(void) testAddStepToWorkflow;

-(void) testInsertStepBefore;

-(void) testInsertStepAfter;

-(void) testRemoveStep;

-(void) testSetStepAfter;

-(void) testStartWorkflow;

-(void) testAdvanceWorkflow;

-(void) testEndWorkflow;

@end
