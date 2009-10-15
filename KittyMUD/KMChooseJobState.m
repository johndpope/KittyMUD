//
//  KMChooseJobState.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/11/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMChooseJobState.h"
#import "KMJob.h"
#import "KMStateMachine.h"
#import "KMPlayingLogic.h"
#import "KMPlayingState.h"
#import "KMRoom.h"
#import "KMCharacter.h"
#import "KMCommandInterpreter.h"
#import "KittyMudStringExtensions.h"

@implementation KMChooseJobState

+(void)initialize {
	[KMStateMachine registerState:[self class]];
}

-(id) init {
	self = [super init];
	if(self) {
		jobs = nil;
		menu = nil;
	}
	return self;
}

-(void) sendMessageToCoordinator:(id)coordinator {
	if(!jobs) {
		jobs = [KMJob getAvailableJobs:[coordinator valueForKeyPath:@"properties.current-character"]];
		menu = [[KMMenuHandler alloc] initializeWithItems:jobs];
	}
	[menu displayMenu:coordinator];
}

-(id<KMState>) processState:(id)coordinator
{
	KMJob* job = [menu getSelection:coordinator];
	if(!job)
		return self;
	KMCharacter* character = [coordinator valueForKeyPath:@"properties.current-character"];
	[character setValue:[job name] forKeyPath:@"properties.job"];
	[character setValue:[KMRoom getDefaultRoom] forKeyPath:@"properties.current-room"];
	[coordinator saveToXML:[@"$(SaveDir)" replaceAllVariables] withState:NO];
	[[character valueForKeyPath:@"properties.current-room"] displayRoom:coordinator];
	KMCommandInterpreter* playingInterpreter = [[KMCommandInterpreter alloc] init];
	[playingInterpreter registerLogic:[KMPlayingLogic class] asDefaultTarget:NO];
	[coordinator setInterpreter:playingInterpreter];
	return [[KMPlayingState alloc] init];
}

+(NSString*) getName
{
	return @"ChooseJob";
}

// Because soft reboot under KittyMUD does not discriminate based on the state, we use this so we can remind players what they were doing after a soft reboot
-(void) softRebootMessage:(id)coordinator
{
	[self sendMessageToCoordinator:coordinator];
}
@synthesize jobs;
@synthesize menu;
@end
