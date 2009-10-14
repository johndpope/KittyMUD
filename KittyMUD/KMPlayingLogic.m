//
//  KMPlayingLogic.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/13/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMPlayingLogic.h"
#import "KittyMudStringExtensions.h"
#import "KMServer.h"
#import "KMConnectionCoordinator.h"
#import "KMExitInfo.h"
#import "KMRoom.h"
#import "KMCharacter.h"
#import "KMCommandInterpreter.h"

@implementation KMPlayingLogic

-(id) initializeWithCommandInterpreter:(id)cmdInterpreter
{
	self = [super init];
	return self;
}

-(void) displayHelpToCoordinator:(id)coordinator
{
	return;
}

-(void) repeatCommandsToCoordinator:(id)coordinator
{
	return;
}

-(BOOL) isRepeating
{
	return NO;
}

CHELP(save,@"Saves your account.",nil)
CIMPL(save,save:,nil,nil,nil,1) {
	[coordinator saveToXML:[@"$(SaveDir)" replaceAllVariables] withState:NO];
}

CHELP(quit,@"Quits the game with saving.",nil)
CIMPL(quit,quit:,nil,nil,nil,1) {
	CMD(save);
	[[[KMServer getDefaultServer] getConnectionPool] removeConnection:coordinator];
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
	if(move)
		[pc setValue:dest forKeyPath:@"properties.current-room"];
	[dest displayRoom:coordinator];
}

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
	} else {
		[[coordinator valueForKeyPath:@"properties.current-character.properties.current-room"] displayRoom:coordinator];
	}
}

CHELP(reboot, @"Performs a soft reboot.", nil)
CIMPL(reboot,reboot:,nil,nil,@"admin",1) {
	[[[KMServer getDefaultServer] getConnectionPool] writeToAllConnections:@"`R*** `YPERFORMING A SOFT REBOOT, PLEASE STANDY... `R***`x"];
	[[KMServer getDefaultServer] softReboot];
}

CIMPL(debugprintflag,debugprintflag:,nil,nil,nil,1) {
	[[coordinator valueForKeyPath:@"properties.current-character"] debugPrintFlagStatus:coordinator];
}
@end
