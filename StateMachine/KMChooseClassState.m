//
//  KMChooseClassState.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/11/09.
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

#import "KMChooseClassState.h"
#import "KMClass.h"

#import "KMPlayingLogic.h"
#import "KMPlayingState.h"
#import "KMRoom.h"
#import "KMCharacter.h"
#import "KMCommandInterpreter.h"
#import "NSString+KMAdditions.h"

@implementation KMChooseClassState

-(void) processState
{
	KMGetMenuFromCoordinator(menu);
	KMClass* klass = [menu getSelection:coordinator];
	if(!klass)
		return;
	KMCharacter* character = [[coordinator properties] objectForKey:@"properties.current-character"];
	if(character) {
		[[character properties] setValue:[klass name] forKeyPath:@"properties.class"];
	} else {
		[coordinator setValue:[klass name] forKeyPath:@"properties.class"];
		[(KMObject*)coordinator setFlag:@"class-before-character"];
	}
	KMGetStateFromCoordinator(state);
	if(state == self) {
		KMSetStateForCoordinatorTo([KMNullState class]);
	}
}

+(NSString*) getName
{
	return @"ChooseJob";
}

// Because soft reboot under KittyMUD does not discriminate based on the state, we use this so we can remind players what they were doing after a soft reboot
-(void) softRebootMessage
{
	KMSoftRebootCheck;
	KMGetMenuFromCoordinator(menu);
	if(!menu) {
		NSArray* klasses = [KMClass getAvailableJobs:[coordinator valueForKeyPath:@"properties.current-character"]];
		menu = [[KMMenuHandler alloc] initWithItems:klasses message:@"Please choose a class from the following selection:>"];
		KMSetMenuForCoordinatorTo(menu);
	}
	[menu displayMenu:coordinator];
}

@end
