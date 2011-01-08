//
//  KMStatAllocationState.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/10/09.
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

#import "KMStatAllocationState.h"
#import "KMConnectionCoordinator.h"
#import "KMCommandInterpreter.h"
#import "KMStatAllocationLogic.h"
#import "KMCharacter.h"
#import <ECScript/ECScript.h>

@implementation KMStatAllocationState

+(void) initialize {
	KMCommandInterpreter* statAllocatableInterpreter = [[KMCommandInterpreter alloc] init];
	[statAllocatableInterpreter registerLogic:[KMStatAllocationLogic class] asDefaultTarget:YES];
	KMSetInterpreterForStateTo(KMStatAllocationState,statAllocatableInterpreter);
}

-(void) processState
{
	return;
}

+(NSString*) getName
{
	return @"StatAllocation";
}

// Because soft reboot under KittyMUD does not discriminate based on the state, we use this so we can remind players what they were doing after a soft reboot
-(void) softRebootMessage
{
	KMSoftRebootCheck;
	KMGetInterpreterForCoordinator(interpreter);
	[(KMStatAllocationLogic*)((KMCommandInterpreter*)[(id)interpreter defaultTarget]) displayStatAllocationScreenToCoordinator:coordinator];
}

@end
