//
//  KMCreateCharacterState.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/19/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//

#import "KMCreateCharacterState.h"
#import "KMConnectionCoordinator.h"
#import "NSString+KMAdditions.h"
#import "KMServer.h"
#import "KMCharacter.h"
#import "KMChooseRaceState.h"
#import "KMStatAllocationState.h"
#import "KMChooseClassState.h"
#import "KMConfirmStatAllocationState.h"
#import "KMWorkflow.h"
#import "KMPlayingState.h"
#import "KMRace.h"

@implementation KMCreateCharacterState

-(void) processState
{
	return;
}

+(NSString*) getName
{
	return @"CreateCharacter";
}

// Because soft reboot under KittyMUD does not discriminate based on the state, we use this so we can remind players what they were doing after a soft reboot
-(void) softRebootMessage
{
	KMSoftRebootCheck;
	[[KMWorkflow getWorkflowForName:KMCreateCharacterWorkflow] startWorkflowForCoordinator:coordinator];
}

+(NSArray*)requirements
{
	return nil;
}

+(NSString*)menuLine
{
	return @"Create a new character";
}

+(int) priority
{
	return 1;
}
@end
