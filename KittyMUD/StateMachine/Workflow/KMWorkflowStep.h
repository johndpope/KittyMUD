//
//  KMWorkflowStep.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/26/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMState.h"

@interface KMWorkflowStep : NSObject {
	id<KMState> myState;
	KMWorkflowStep* nextStep;
}

-(id) initWithState:(id<KMState>)state;

@property (retain) id<KMState> myState;
@property (retain) KMWorkflowStep* nextStep;
@end
