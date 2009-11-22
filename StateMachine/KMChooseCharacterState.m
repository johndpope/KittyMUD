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

+(void) processState:(id)coordinator
{
	KMGetMenuFromCoordinator(menu);
	KMCharacter* character = [menu getSelection:coordinator];
	if(!character)
		return;
	[coordinator setValue:character forKeyPath:@"properties.current-character"];
	KMSetStateForCoordinatorTo(KMPlayingState);
}

+(NSString*) getName
{
	return @"ChooseCharacter";
}

// Because soft reboot under KittyMUD does not discriminate based on the state, we use this so we can remind players what they were doing after a soft reboot
+(void) softRebootMessage:(id)coordinator
{
	KMGetMenuFromCoordinator(menu);
	if(!menu) {
		menu = [[KMMenuHandler alloc] initializeWithItems:[coordinator getCharacters]];
		KMSetMenuForCoordinatorTo(menu);
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

@end
