//
//  KMChooseRaceState.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/5/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMChooseRaceState.h"
#import "KMRace.h"
#import "KMCharacter.h"
#import "KMCommandInterpreter.h"
#import "KMStatAllocationLogic.h"
#import "KMStatCopy.h"
#import "KMStatAllocationState.h"


@implementation KMChooseRaceState

-(void) processState:(id)coordinator
{
	KMGetMenuFromCoordinator(menu);
	KMRace* race = [menu getSelection:coordinator];
	if(!race)
		return;
	KMCharacter* character = [[coordinator getProperties] objectForKey:@"properties.current-character"];
	if(character) {
		[[character getProperties] setValue:[race name] forKeyPath:@"properties.race"];
		[[character stats] copyStat:[race bonuses] withSettings:KMStatCopySettingsValue];
	} else {
		[coordinator setValue:[race name] forKeyPath:@"properties.race"];
		[(KMObject*)coordinator setFlag:@"race-before-character"];
	}
	
	KMGetStateFromCoordinator(state);
	if(state == self) {
		KMSetStateForCoordinatorTo([KMNullState class]);
	}
}

+(NSString*) getName
{
	return @"ChooseRace";
}

// Because soft reboot under KittyMUD does not discriminate based on the state, we use this so we can remind players what they were doing after a soft reboot
-(void) softRebootMessage:(id)coordinator
{
	KMSoftRebootCheck;
	KMGetMenuFromCoordinator(menu);
	if(!menu) {
		menu = [[KMMenuHandler alloc] initWithItems:[KMRace getAllRaces] message:@"Please choose a race from the following selection:>"];
		KMSetMenuForCoordinatorTo(menu);
	}
	[menu displayMenu:coordinator];
}

@end
