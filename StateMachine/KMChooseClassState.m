//
//  KMChooseClassState.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/11/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMChooseClassState.h"
#import "KMClass.h"

#import "KMPlayingLogic.h"
#import "KMPlayingState.h"
#import "KMRoom.h"
#import "KMCharacter.h"
#import "KMCommandInterpreter.h"
#import "NSString+KMAdditions.h"

@implementation KMChooseClassState

-(id) init {
	self = [super init];
	if(self) {
		klasses = nil;
		menu = nil;
	}
	return self;
}

-(id<KMState>) processState:(id)coordinator
{
	KMClass* klass = [menu getSelection:coordinator];
	if(!klass)
		return self;
	KMCharacter* character = [coordinator valueForKeyPath:@"properties.current-character"];
	[character setValue:[klass name] forKeyPath:@"properties.class"];
	[character setValue:[KMRoom getDefaultRoom] forKeyPath:@"properties.current-room"];
	[coordinator saveToXML:[@"$(SaveDir)" replaceAllVariables]];
	KMCommandInterpreter* playingInterpreter = [[KMCommandInterpreter alloc] init];
	[playingInterpreter registerLogic:[KMPlayingLogic class] asDefaultTarget:NO];
	[coordinator setInterpreter:playingInterpreter];
	return [[KMPlayingState alloc] init];
}

-(NSString*) getName
{
	return @"ChooseJob";
}

// Because soft reboot under KittyMUD does not discriminate based on the state, we use this so we can remind players what they were doing after a soft reboot
-(void) softRebootMessage:(id)coordinator
{
	if(!klasses) {
		klasses = [KMClass getAvailableJobs:[coordinator valueForKeyPath:@"properties.current-character"]];
		menu = [[KMMenuHandler alloc] initializeWithItems:klasses];
	}
	[menu displayMenu:coordinator];
}
@synthesize klasses;
@synthesize menu;
@end
