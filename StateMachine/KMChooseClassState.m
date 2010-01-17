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
	KMCharacter* character = [[coordinator getProperties] objectForKey:@"properties.current-character"];
	if(character) {
		[[character getProperties] setValue:[klass name] forKeyPath:@"properties.class"];
	} else {
		[coordinator setValue:[klass name] forKeyPath:@"properties.class"];
		[(KMObject*)coordinator setFlag:@"class-before-character"];
	}
	KMGetStateFromCoordinator(state);
	if(state == self) {
		KMSetStateForCoordinatorTo(KMNullState);
	}
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
