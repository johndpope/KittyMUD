//
//  KittyMUD.h"
//  KittyMUD
//
//  Created by Michael Tindal on 10/29/09.
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

#import <Cocoa/Cocoa.h>
#import "KMAccountMenu.h"
#import "KMAccountMenuState.h"
#import "KMAccountNameState.h"
#import "KMBasicInterpreter.h"
#import "KMCharacter.h"
#import "KMChooseCharacterState.h"
#import "KMChooseClassState.h"
#import "KMChooseRaceState.h"
#import "KMClass.h"
#import "KMColorProcessWriteHook.h"
#import "KMCommandInfo.h"
#import "KMCommandInterpreter.h"
#import "KMCommandInterpreterLogic.h"
#import "KMConfirmPasswordState.h"
#import "KMConfirmStatAllocationState.h"
#import "KMConnectionCoordinator.h"
#import "KMConnectionPool.h"
#import "KMCreateCharacterState.h"
#import "KMDataManager.h"
#import "KMDataStartup.h"
#import "KMExitInfo.h"
#import "KMInfoDisplay.h"
#import "KMInterpreter.h"
#import "KMItemEnhancement.h"
#import "KMItemTemplate.h"
#import "KMMenu.h"
#import "KMMenuHandler.h"
#import "KMNewPasswordState.h"
#import "KMPlayingLogic.h"
#import "KMPlayingState.h"
#import "KMQuitState.h"
#import "KMRace.h"
#import "KMRoom.h"
#import "KMServer.h"
#import "KMStack.h"
#import "KMStat.h"
#import "KMStatAllocationLogic.h"
#import "KMStatAllocationState.h"
#import "KMStatCopy.h"
#import "KMState.h"
#import "KMVariableHook.h"
#import "KMVariableManager.h"
#import "KMWorkflow.h"
#import "KMWorkflowStep.h"
#import "KMWriteHook.h"
#import "NSString+KMAdditions.h"
#import "KMAchievement.h"
#import "KMAchievementEngine.h"
#import "KMChooseCharacterNameState.h"
#import "KMSpecial.h"
#import "KMExtensibleDataLoader.h"
#import "KMExtensibleDataSchema.h"
#import "KMEventDuration.h"
#import "KMEnumFactory.h"

#define KMSoftRebootCheck if([coordinator isFlagSet:@"softreboot-displayed"]) return; [coordinator setFlag:@"softreboot-displayed"]

#define KMCurrentCharacter(coor) [coor valueForKeyPath:@"properties.current-character"]

