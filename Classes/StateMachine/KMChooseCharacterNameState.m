//
//  KMChooseCharacterNameState.m
//  KittyMUD
//
//  Created by Michael Tindal on 11/23/09.
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

#import "KMChooseCharacterNameState.h"
#import "KMRace.h"
#import "KMClass.h"
#import "NSString+KMAdditions.h"
#import "KMConnectionCoordinator.h"
#import <ECScript/ECScript.h>

static NSMutableDictionary* tmpCharNames = nil; // so we can't create characters with the same name while one is in the character creation process

@implementation KMChooseCharacterNameState

+(void) initialize {
    if(!tmpCharNames) {
        tmpCharNames  = [NSMutableDictionary dictionary];
    }
}

-(void) processState {
	NSFileHandle* usedNamesFile = [NSFileHandle fileHandleForReadingAtPath:[@"$(UsedCharacterFile)" replaceAllVariables]];
	NSString* name = [coordinator inputBuffer];
	if(usedNamesFile != nil)
	{
		NSArray* names = [[[NSString alloc] initWithData:[usedNamesFile readDataToEndOfFile] encoding:NSUTF8StringEncoding] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		NSPredicate* pred = [NSPredicate predicateWithFormat:@"self like[cd] %@", name];
		if([[names filteredArrayUsingPredicate:pred] count] > 0) {
			[coordinator sendMessageToBuffer:@"Character name already in use, please choose another."];
			return;
		}
	} else {
		[[NSFileManager defaultManager] createFileAtPath:[@"$(UsedCharacterFile)" replaceAllVariables] contents:nil attributes:nil];
	}
    if([tmpCharNames objectForKey:name]) {
        [coordinator sendMessageToBuffer:@"Character name already in use, please choose another."];
        return;
    } else {
        [tmpCharNames setObject:BL(YES) forKey:name];
    }
	[(KMConnectionCoordinator*)coordinator setFlag:[NSString stringWithFormat:@"new-character-%@",name]];
	[(KMConnectionCoordinator*)coordinator setFlag:@"has-character"];
	KMCharacter* character = nil;
	if(![coordinator valueForKeyPath:@"properties.current-character"]) {
		character = [[KMCharacter alloc] initWithName:name];
	} else {
		character = [coordinator valueForKeyPath:@"properties.current-character"];
	}
	if([coordinator isFlagSet:@"race-before-character"]) {
		NSString* r = [coordinator valueForKeyPath:@"properties.race"];
		KMRace* race = [KMRace getRaceByName:r];
		[[character properties] setObject:[race name] forKey:@"race"];
		if(![coordinator isFlagSet:@"race-bonuses-after-allocation"]) {
			[[character stats] copyStat:[race bonuses] withSettings:KMStatCopySettingsValue];
		}
		[coordinator setValue:nil forKeyPath:@"properties.race"];
		[coordinator clearFlag:@"race-before-character"];
	}
	if([coordinator isFlagSet:@"class-before-character"]) {
		NSString* c = [coordinator valueForKeyPath:@"properties.class"];
		KMClass* klass = [KMClass getClassByName:c];
		[[character properties] setObject:[klass name] forKey:@"class"];
		[coordinator setValue:nil forKeyPath:@"properties.class"];
		[coordinator clearFlag:@"class-before-character"];
	}
	// we do this here because its the only time we can gaurantee we have a character
	[[character stats] setValueOfChildAtPath:[NSString stringWithFormat:@"class::%@",[character valueForKeyPath:@"properties.class"]] withValue:1];
	[[character stats] setValueOfChildAtPath:[NSString stringWithFormat:@"race::%@",[character valueForKeyPath:@"properties.race"]] withValue:1];
	[coordinator setValue:character forKeyPath:@"properties.current-character"];
	[[coordinator characters] addObject:character];
	KMGetStateFromCoordinator(state);
	if(state == self) {
		KMSetStateForCoordinatorTo([KMNullState class]);
	}
}

+(NSString*) getName
{
	return @"ChooseCharacterName";
}

// Because soft reboot under KittyMUD does not discriminate based on the state, we use this so we can remind players what they were doing after a soft reboot
-(void) softRebootMessage
{
	KMSoftRebootCheck;
	[coordinator sendMessageToBuffer:@"Please enter a name for your new character:"];
}

@end
