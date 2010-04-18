//
//  KMPlayingState.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/13/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as 
// published by the Free Software Foundation; either version 3 of 
// the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
//

#import "KMPlayingState.h"
#import "NSString+KMAdditions.h"
#import "KMCharacter.h"
#import "KMConnectionCoordinator.h"
#import "KMRoom.h"
#import "KMCommandInterpreter.h"
#import "KMPlayingLogic.h"

@implementation KMPlayingState

+(void) initialize {
	KMCommandInterpreter* playingInterpreter = [[KMCommandInterpreter alloc] init];
	[playingInterpreter registerLogic:[KMPlayingLogic class] asDefaultTarget:NO];
	KMSetInterpreterForStateTo(KMPlayingState,playingInterpreter);
}

-(void) processState
{
	return;
}

+(NSString*) getName
{
	return @"Playing";
}

// Because soft reboot under KittyMUD does not discriminate based on the state, we use this so we can remind players what they were doing after a soft reboot
-(void) softRebootMessage
{
	KMSoftRebootCheck;
	if(![coordinator isFlagSet:@"no-display-room"])
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