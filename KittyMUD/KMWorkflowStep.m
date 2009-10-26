//
//  KMWorkflowStep.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/26/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMWorkflowStep.h"


@implementation KMWorkflowStep

-(id) initWithState:(id KMState)state {
	self = [super init];
	if(self) {
		myState = state;
	}
}

@synthesize myState;
@synthesize nextStep;
@end
