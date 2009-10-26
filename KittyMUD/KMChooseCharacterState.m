//
//  KMChooseCharacterState.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/21/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMChooseCharacterState.h"

#import "KMCommandInterpreter.h"
#import "KMPlayingState.h"
#import "KMPlayingLogic.h"

@implementation KMChooseCharacterState

-(id) init {
	self = [super init];
	if(self) {
		menu = nil;
	}
	return self;
}

-(id<KMState>) processState:(id)coordinator
{
	KMCharacter* character = [menu getSelection:coordinator];
	if(!character)
		return self;
	[coordinator setFlag:@"no-message"];
	[coordinator setValue:character forKeyPath:@"properties.current-character"];
	[[character valueForKeyPath:@"properties.current-room"] displayRoom:coordinator];
	KMCommandInterpreter* playingInterpreter = [[KMCommandInterpreter alloc] init];
	[playingInterpreter registerLogic:[KMPlayingLogic class] asDefaultTarget:NO];
	[coordinator setInterpreter:playingInterpreter];
	return [[KMPlayingState alloc] init];
}

+(NSString*) getName
{
	return @"ChooseCharacter";
}

// Because soft reboot under KittyMUD does not discriminate based on the state, we use this so we can remind players what they were doing after a soft reboot
-(void) softRebootMessage:(id)coordinator
{
	if(!menu) {
		menu = [[KMMenuHandler alloc] initializeWithItems:[coordinator getCharacters]];
	}
	[menu displayMenu:coordinator];
}

+(NSArray*)requirements
{
	return [NSArray arrayWithObject:@"has-character"];
}

+(NSString*)menuLine
{
	return @"Choose an existing character.";
}

+(int) priority
{
	return 2;
}

@synthesize menu;
@end
