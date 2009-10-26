//
//  KMPlayingState.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/13/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMPlayingState.h"
#import "KMString.h"
#import "KMCharacter.h"
#import "KMConnectionCoordinator.h"
#import "KMRoom.h"
#import "KMCommandInterpreter.h"
#import "KMPlayingLogic.h"

@implementation KMPlayingState

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
	if([coordinator isFlagSet:@"soft-reboot"])
		[[coordinator valueForKeyPath:@"properties.current-character.properties.current-room"] displayRoom:coordinator];
	NSMutableDictionary* promptVars = [[NSMutableDictionary alloc] init];
	NSString* prompt = [coordinator valueForKeyPath:@"properties.current-character.properties.prompt"];
	NSDictionary* values = [NSDictionary dictionaryWithObjectsAndKeys:@"curhp",@"CurHp",@"maxhp",@"MaxHp",@"curmp",@"CurMp",@"maxmp",@"MaxMp",@"level",@"Lvl",@"xp",@"Xp",nil];
	for(NSString* var in [values allKeys]) {
		NSNumber* num = [NSNumber numberWithInt:[[[[coordinator valueForKeyPath:@"properties.current-character"] stats] findStatWithPath:[values objectForKey:var]] statvalue]];
		[promptVars setObject:[num stringValue] forKey:var];
	}
	
	[coordinator sendMessageToBuffer:[prompt replaceAllVariablesWithDictionary:promptVars]];
}

@end