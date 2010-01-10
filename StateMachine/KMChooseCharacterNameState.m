//
//  KMChooseCharacterNameState.m
//  KittyMUD
//
//  Created by Michael Tindal on 11/23/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//

#import "KMChooseCharacterNameState.h"
#import "KMRace.h"
#import "NSString+KMAdditions.h"
#import "KMConnectionCoordinator.h"
#import <XSHRuntime/XSHRuntime.h>

@implementation KMChooseCharacterNameState

+(void) processState:(id)coordinator {
	NSFileHandle* usedNamesFile = [NSFileHandle fileHandleForReadingAtPath:[@"$(UsedCharacterFile)" replaceAllVariables]];
	NSString* name = [coordinator getInputBuffer];
	if(usedNamesFile != nil)
	{
		NSArray* names = [[[NSString alloc] initWithData:[usedNamesFile readDataToEndOfFile] encoding:NSUTF8StringEncoding] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		NSPredicate* pred = [NSPredicate predicateWithFormat:@"self like[cd] %@", name];
		if([[names filteredArrayUsingPredicate:pred] count] > 0) {
			[coordinator sendMessageToBuffer:@"Character name already in use, please choose another."];
			[self softRebootMessage:coordinator];
			return;
		}
	} else {
		[[NSFileManager defaultManager] createFileAtPath:[@"$(UsedCharacterFile)" replaceAllVariables] contents:nil attributes:nil];
	}
	[coordinator setFlag:[NSString stringWithFormat:@"new-character-%@",name]];
	[coordinator setFlag:@"has-character"];
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
	[coordinator setValue:character forKeyPath:@"properties.current-character"];
	[[coordinator getCharacters] addObject:character];
	XSHNode* node = [XSHNode createNodeFromSource:@"coordinator->makeChoice(['acid','cold','fire','lightning','poison']);"];
	[[node scope] registerVariable:coordinator withName:@"coordinator"];
	[node execute];
	[NSThread sleepForTimeInterval:.05];
	KMGetStateFromCoordinator(state);
	if(state == self) {
		KMSetStateForCoordinatorTo(KMNullState);
	}
}

+(NSString*) getName
{
	return @"ChooseCharacterName";
}

// Because soft reboot under KittyMUD does not discriminate based on the state, we use this so we can remind players what they were doing after a soft reboot
+(void) softRebootMessage:(id)coordinator
{
	[coordinator sendMessageToBuffer:@"Please enter a name for your new character:"];
}

@end
