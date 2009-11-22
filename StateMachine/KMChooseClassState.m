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

+(void) processState:(id)coordinator
{
	KMGetMenuFromCoordinator(menu);
	KMClass* klass = [menu getSelection:coordinator];
	if(!klass)
		return;
	KMCharacter* character = [coordinator valueForKeyPath:@"properties.current-character"];
	[character setValue:[klass name] forKeyPath:@"properties.class"];
	[character setValue:[KMRoom getDefaultRoom] forKeyPath:@"properties.current-room"];
	[coordinator saveToXML:[@"$(SaveDir)" replaceAllVariables]];
	KMSetStateForCoordinatorTo(KMPlayingState);
}

+(NSString*) getName
{
	return @"ChooseJob";
}

// Because soft reboot under KittyMUD does not discriminate based on the state, we use this so we can remind players what they were doing after a soft reboot
+(void) softRebootMessage:(id)coordinator
{
	KMGetMenuFromCoordinator(menu);
	if(!menu) {
		NSArray* klasses = [KMClass getAvailableJobs:[coordinator valueForKeyPath:@"properties.current-character"]];
		menu = [[KMMenuHandler alloc] initializeWithItems:klasses];
		KMSetMenuForCoordinatorTo(menu);
	}
	[menu displayMenu:coordinator];
}

@end
