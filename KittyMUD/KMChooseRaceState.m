//
//  KMChooseRaceState.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/5/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMChooseRaceState.h"
#import "KMRace.h"
#import "KMCharacter.h"
#import "KMCommandInterpreter.h"
#import "KMStatAllocationLogic.h"
#import "KMStatCopy.h"
#import "KMStatAllocationState.h"
#import "KMStateMachine.h"

@implementation KMChooseRaceState

+(void)initialize {
	[KMStateMachine registerState:[self class]];
}

-(id)init
{
	self = [super init];
	if(self)
		menu = [[KMMenuHandler alloc] initializeWithItems:[KMRace getAllRaces]];
	return self;
}

-(id<KMState>) processState:(id)coordinator
{
	KMRace* race = [menu getSelection:coordinator];
	if(!race)
		return self;
	KMCharacter* character = [[coordinator getProperties] objectForKey:@"current-character"];
	[[character getProperties] setObject:[race name] forKey:@"race"];
	[[character stats] copyStat:[race bonuses]];
	KMCommandInterpreter* statAllocatableInterpreter = [[KMCommandInterpreter alloc] init];
	[statAllocatableInterpreter registerLogic:[KMStatAllocationLogic class] asDefaultTarget:YES];
	[coordinator setInterpreter:statAllocatableInterpreter];
	return [[KMStatAllocationState alloc] init];
}

+(NSString*) getName
{
	return @"ChooseRace";
}

// Because soft reboot under KittyMUD does not discriminate based on the state, we use this so we can remind players what they were doing after a soft reboot
-(void) softRebootMessage:(id)coordinator
{
	[self sendMessageToCoordinator:coordinator];
}

-(void) sendMessageToCoordinator:(id)coordinator
{
	[menu displayMenu:coordinator];
}

@synthesize menu;
@end
