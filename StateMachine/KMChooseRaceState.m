//
//  KMChooseRaceState.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/5/09.
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

#import "KMChooseRaceState.h"
#import "KMRace.h"
#import "KMCharacter.h"
#import "KMCommandInterpreter.h"
#import "KMStatAllocationLogic.h"
#import "KMStatCopy.h"
#import "KMStatAllocationState.h"


@implementation KMChooseRaceState

-(void) processState
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
-(void) softRebootMessage
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
