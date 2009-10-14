//
//  KMStatAllocationState.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/10/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMStatAllocationState.h"
#import "KMConnectionCoordinator.h"
#import "KMCommandInterpreter.h"
#import "KMStatAllocationLogic.h"
#import "KMStateMachine.h"

@implementation KMStatAllocationState

+(void)initialize {
	[KMStateMachine registerState:[self class]];
}

-(void) sendMessageToCoordinator:(id)coordinator
{
	[[[coordinator interpreter] defaultTarget] displayStatAllocationScreenToCoordinator:coordinator];
}

-(id<KMState>) processState:(id)coordinator
{
	return self;
}

+(NSString*) getName
{
	return @"StatAllocation";
}

// Because soft reboot under KittyMUD does not discriminate based on the state, we use this so we can remind players what they were doing after a soft reboot
-(void) softRebootMessage:(id)coordinator
{
	KMCommandInterpreter* statAllocatableInterpreter = [[KMCommandInterpreter alloc] init];
	[statAllocatableInterpreter registerLogic:[KMStatAllocationLogic class] asDefaultTarget:YES];
	[coordinator setInterpreter:statAllocatableInterpreter];
	[self sendMessageToCoordinator:coordinator];
}

@end
