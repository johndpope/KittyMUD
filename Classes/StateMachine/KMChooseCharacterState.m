//
//  KMChooseCharacterState.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/21/09.
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

#import "KMChooseCharacterState.h"

#import "KMCommandInterpreter.h"
#import "KMPlayingState.h"
#import "KMPlayingLogic.h"

@implementation KMChooseCharacterState

-(void) processState
{
	KMGetMenuFromCoordinator(menu);
	KMCharacter* character = [menu getSelection:coordinator];
	if(!character)
		return;
	[coordinator setValue:character forKeyPath:@"properties.current-character"];
	KMSetStateForCoordinatorTo([KMPlayingState class]);
}

+(NSString*) getName
{
	return @"ChooseCharacter";
}

// Because soft reboot under KittyMUD does not discriminate based on the state, we use this so we can remind players what they were doing after a soft reboot
-(void) softRebootMessage
{
	KMSoftRebootCheck;
	KMGetMenuFromCoordinator(menu);
	if(!menu) {
		menu = [[KMMenuHandler alloc] initWithItems:[coordinator characters]];
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
