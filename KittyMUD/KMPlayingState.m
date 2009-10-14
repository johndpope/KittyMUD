//
//  KMPlayingState.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/13/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMPlayingState.h"
#import "KittyMudStringExtensions.h"
#import "KMCharacter.h"
#import "KMConnectionCoordinator.h"
#import "KMStateMachine.h"
#import "KMCommandInterpreter.h"
#import "KMPlayingLogic.h"

@implementation KMPlayingState

+(void)initialize {
	[KMStateMachine registerState:[self class]];
}

-(void) sendMessageToCoordinator:(id)coordinator
{
	NSMutableDictionary* promptVars = [[NSMutableDictionary alloc] init];
	NSString* prompt = [coordinator valueForKeyPath:@"properties.current-character.properties.prompt"];
	NSDictionary* values = [NSDictionary dictionaryWithObjectsAndKeys:@"curhp",@"CurHp",@"maxhp",@"MaxHp",@"curmp",@"CurMp",@"maxmp",@"MaxMp",@"level",@"Lvl",@"xp",@"Xp",nil];
	for(NSString* var in [values allKeys]) {
		NSNumber* num = [NSNumber numberWithInt:[[[[coordinator valueForKeyPath:@"properties.current-character"] stats] findStatWithPath:[values objectForKey:var]] statvalue]];
		[promptVars setObject:[num stringValue] forKey:var];
	}
	
	[coordinator sendMessageToBuffer:[prompt replaceAllVariablesWithDictionary:promptVars]];
}

-(id<KMState>) processState:(id)coordinator
{
	return self;
}

+(NSString*) getName
{
	return @"Playing";
}

// Because soft reboot under KittyMUD does not discriminate based on the state, we use this so we can remind players what they were doing after a soft reboot
-(void) softRebootMessage:(id)coordinator
{
	KMCommandInterpreter* playingInterpreter = [[KMCommandInterpreter alloc] init];
	[playingInterpreter registerLogic:[KMPlayingLogic class] asDefaultTarget:NO];
	[coordinator setInterpreter:playingInterpreter];
	[[coordinator valueForKeyPath:@"properties.current-character.properties.current-room"] displayRoom:coordinator];
	[self sendMessageToCoordinator:coordinator];
}

@end