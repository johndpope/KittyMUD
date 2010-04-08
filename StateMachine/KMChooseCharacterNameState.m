//
//  KMChooseCharacterNameState.m
//  KittyMUD
//
//  Created by Michael Tindal on 11/23/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//

#import "KMChooseCharacterNameState.h"
#import "KMRace.h"
#import "KMClass.h"
#import "NSString+KMAdditions.h"
#import "KMConnectionCoordinator.h"
#import <ECScript/ECScript.h>

@implementation KMChooseCharacterNameState

-(void) processState {
	NSFileHandle* usedNamesFile = [NSFileHandle fileHandleForReadingAtPath:[@"$(UsedCharacterFile)" replaceAllVariables]];
	NSString* name = [coordinator getInputBuffer];
	if(usedNamesFile != nil)
	{
		NSArray* names = [[[NSString alloc] initWithData:[usedNamesFile readDataToEndOfFile] encoding:NSUTF8StringEncoding] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		NSPredicate* pred = [NSPredicate predicateWithFormat:@"self like[cd] %@", name];
		if([[names filteredArrayUsingPredicate:pred] count] > 0) {
			[coordinator sendMessageToBuffer:@"Character name already in use, please choose another."];
			[self softRebootMessage];
			return;
		}
	} else {
		[[NSFileManager defaultManager] createFileAtPath:[@"$(UsedCharacterFile)" replaceAllVariables] contents:nil attributes:nil];
	}
	[(KMConnectionCoordinator*)coordinator setFlag:[NSString stringWithFormat:@"new-character-%@",name]];
	[(KMConnectionCoordinator*)coordinator setFlag:@"has-character"];
	KMCharacter* character = nil;
	if(![coordinator valueForKeyPath:@"properties.current-character"]) {
		character = [[KMCharacter alloc] initializeWithName:name];
	} else {
		character = [coordinator valueForKeyPath:@"properties.current-character"];
	}
	if([coordinator isFlagSet:@"race-before-character"]) {
		NSString* r = [coordinator valueForKeyPath:@"properties.race"];
		KMRace* race = [KMRace getRaceByName:r];
		[[character getProperties] setObject:[race name] forKey:@"race"];
		if(![coordinator isFlagSet:@"race-bonuses-after-allocation"]) {
			[[character stats] copyStat:[race bonuses] withSettings:KMStatCopySettingsValue];
		}
		[coordinator setValue:nil forKeyPath:@"properties.race"];
		[coordinator clearFlag:@"race-before-character"];
	}
	if([coordinator isFlagSet:@"class-before-character"]) {
		NSString* c = [coordinator valueForKeyPath:@"properties.class"];
		KMClass* klass = [KMClass getClassByName:c];
		[[character getProperties] setObject:[klass name] forKey:@"class"];
		[coordinator setValue:nil forKeyPath:@"properties.class"];
		[coordinator clearFlag:@"class-before-character"];
	}
	// we do this here because its the only time we can gaurantee we have a character
	[[character stats] setValueOfChildAtPath:[NSString stringWithFormat:@"class::%@",[character valueForKeyPath:@"properties.class"]] withValue:1];
	[[character stats] setValueOfChildAtPath:[NSString stringWithFormat:@"race::%@",[character valueForKeyPath:@"properties.race"]] withValue:1];
	[coordinator setValue:character forKeyPath:@"properties.current-character"];
	[[coordinator getCharacters] addObject:character];
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
