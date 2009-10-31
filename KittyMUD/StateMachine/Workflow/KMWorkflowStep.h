//
//  KMWorkflowStep.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/26/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMState.h"
#import "KMObject.h"

@interface  KMWorkflowStep  : KMObject {
	id<KMState> myState;
	KMWorkflowStep* nextStep;
}

-(id) initWithState:(id<KMState>)state;

@property (retain) id<KMState> myState;
@property (retain) KMWorkflowStep* nextStep;
@end
