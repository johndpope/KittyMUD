//
//  KMPlayingLogic.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/13/09.
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

#import "KMPlayingLogic.h"
#import "NSString+KMAdditions.h"
#import "KMServer.h"
#import "KMConnectionCoordinator.h"
#import "KMExitInfo.h"
#import "KMRoom.h"
#import "KMCharacter.h"
#import "KMCommandInterpreter.h"

@implementation KMPlayingLogic

-(id) initWithCommandInterpreter:(id) __unused cmdInterpreter
{
	self = [super init];
	return self;
}

-(void) displayHelpToCoordinator:(id) __unused coordinator
{
	return;
}

-(void) repeatCommandsToCoordinator:(id) __unused coordinator
{
	return;
}

-(BOOL) isRepeating
{
	return NO;
}

CHELP(save,@"Saves your account.",nil)
CIMPL(save,save:,nil,nil,nil,1) {
    [coordinator clearFlag:@"no-display-room"];
	[coordinator saveToXML:[@"$(SaveDir)" replaceAllVariables]];
}

CHELP(quit,@"Quits the game with saving.",nil)
CIMPL(quit,quit:,nil,nil,nil,1) {
    [self CMD(save)];
	[[[KMServer defaultServer] connectionPool] removeConnection:coordinator];
}

static void moveBase(KMConnectionCoordinator* coordinator, KMExitDirection exitDir, BOOL move) {
	KMCharacter* pc = [coordinator valueForKeyPath:@"properties.current-character"];
	KMRoom* room = [pc valueForKeyPath:@"properties.current-room"];
	
	NSPredicate* dirTest = [NSPredicate predicateWithFormat:@"self.direction == %d", exitDir];
	NSArray* exits = [[room exitInfo] filteredArrayUsingPredicate:dirTest];
	if([exits count] == 0)
	{
		[coordinator sendMessageToBuffer:@"No exit in that direction."];
		return;
	}
	
	KMExitInfo* moveTo = [exits objectAtIndex:0];
	
	if([moveTo isLocked]) {
		NSString* lockId = [moveTo lockId];
		KMStat* lock = [[pc stats] findStatWithPath:[NSString stringWithFormat:@"items::%@", lockId]];
		if(lock == nil || [lock statvalue] <= 0) {
			[coordinator sendMessageToBuffer:@"Exit is locked."];
			return;
		}
	}
	
	KMRoom* dest = [moveTo room];
	if(move) {
		[coordinator setFlag:@"no-display-room"];
		[pc setValue:dest forKeyPath:@"properties.current-room"];
        [dest displayRoom:coordinator];
	} else {
        [dest displayRoom:coordinator];
    }
}

KMExitDirection directionFromString(NSString*);
KMExitDirection directionFromString( NSString* dir ) {
	if([@"north" hasPrefix:dir])
		return KMExitNorth;
	if([@"south" hasPrefix:dir])
		return KMExitSouth;
	if([@"west" hasPrefix:dir])
		return KMExitWest;
	if([@"east" hasPrefix:dir])
		return KMExitEast;
	if([@"up" hasPrefix:dir])
		return KMExitUp;
	if([@"down" hasPrefix:dir])
		return KMExitDown;
    return (KMExitDirection)-1;
}

CHELP(north,@"Moves your character north.",nil)
CIMPL(north,north:,nil,nil,nil,1) {
	moveBase(coordinator, KMExitNorth, YES);
}

CHELP(south,@"Moves your character south.",nil)
CIMPL(south,south:,nil,nil,nil,1) {
	moveBase(coordinator, KMExitSouth, YES);
}

CHELP(west,@"Moves your character west.",nil)
CIMPL(west,west:,nil,nil,nil,1) {
	moveBase(coordinator, KMExitWest, YES);
}

CHELP(east,@"Moves your character east.",nil)
CIMPL(east,east:,nil,nil,nil,1) {
	moveBase(coordinator, KMExitEast, YES);
}

CHELP(up,@"Moves your character up.",nil)
CIMPL(up,up:,nil,nil,nil,1) {
	moveBase(coordinator, KMExitUp, YES);
}

CHELP(down,@"Moves your character down.",nil)
CIMPL(down,down:,nil,nil,nil,1) {
	moveBase(coordinator, KMExitDown, YES);
}

CHELP(look, @"Looks around.  Optionally takes a direction to look in.", nil)
CIMPL(look,look:direction:,@"direction",nil,nil,1) direction:(NSString*)dir {
	KMExitDirection edir;
	BOOL lookDir = NO;
	if(dir != nil) {
		edir = directionFromString(dir);
		lookDir = YES;
	}
	
	if(lookDir) {
		moveBase(coordinator,edir,NO);
		[(KMObject*)coordinator setFlag:@"no-display-room"];
	} else {
		[(KMObject*)coordinator setFlag:@"no-display-room"];
		[[coordinator valueForKeyPath:@"properties.current-character.properties.current-room"] displayRoom:coordinator];
	}
}

static int rebootTime = 0;

-(void) realSoftReboot:(NSTimer*) __unused timer {
	if(rebootTime > 0) {
		rebootTime--;
		BOOL displayWarning = NO;
		NSString* warningColor = @"`W";
		if(rebootTime >= 30 && (rebootTime % 10 == 0)) {
			warningColor = @"`G";
			displayWarning = YES;
		} else if(rebootTime >= 10 && (rebootTime % 5 == 0)) {
			displayWarning = YES;
			warningColor = @"`Y";
		} else {
			displayWarning = YES;
			warningColor = @"`R";
		}
		if(displayWarning)
			[[[KMServer defaultServer] connectionPool] writeToAllConnections:[NSString stringWithFormat:@"`!`W*** #!%@PERFORMING A SOFT REBOOT in %d minutes `!`W***#!`x",warningColor,rebootTime]];
	} else {
		[[[KMServer defaultServer] connectionPool] writeToAllConnections:@"`!`W*** #!`RPERFORMING A SOFT REBOOT, PLEASE STANDBY... `!`W***#!`x"];
		[[KMServer defaultServer] softReboot];
	}
}

CHELP(reboot, @"Performs a soft reboot.", nil)
CIMPL(reboot,reboot:time:,@"time",nil,@"admin",1) time:(int)time {
#pragma unused(coordinator)
	rebootTime = time;
	if(time > 0) {
		NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
		NSTimer* timer = [NSTimer timerWithTimeInterval:60 target:self selector:@selector(realSoftReboot:) userInfo:nil repeats:YES];
		[runLoop addTimer:timer forMode:NSRunLoopCommonModes]; 
		[[[KMServer defaultServer] connectionPool] writeToAllConnections:[NSString stringWithFormat:@"`!`R*** #!`WPERFORMING A SOFT REBOOT in %d minutes `!`R***#!`x",rebootTime]];
	}
	else {
		[self realSoftReboot:nil];
	}

}
@end
