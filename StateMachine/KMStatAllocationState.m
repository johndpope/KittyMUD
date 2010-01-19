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
#import "KMCharacter.h"
#import <ECScript/ECScript.h>

@implementation KMStatAllocationState

+(void) initialize {
	KMCommandInterpreter* statAllocatableInterpreter = [[KMCommandInterpreter alloc] init];
	[statAllocatableInterpreter registerLogic:[KMStatAllocationLogic class] asDefaultTarget:YES];
	KMSetInterpreterForStateTo(KMStatAllocationState,statAllocatableInterpreter);
}

-(void) processState:(id)coordinator
{
	return;
}

+(NSString*) getName
{
	return @"StatAllocation";
}

// Because soft reboot under KittyMUD does not discriminate based on the state, we use this so we can remind players what they were doing after a soft reboot
-(void) softRebootMessage:(id)coordinator
{
	KMSoftRebootCheck;
	KMGetInterpreterForCoordinator(interpreter);
	[(KMStatAllocationLogic*)((KMCommandInterpreter*)[(id)interpreter defaultTarget]) displayStatAllocationScreenToCoordinator:coordinator];
}

@end
