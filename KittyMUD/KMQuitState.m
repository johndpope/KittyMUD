//
//  KMQuitState.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/21/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMQuitState.h"
#import "KMServer.h"


@implementation KMQuitState

-(id<KMState>) processState:(id)coordinator
{
	[[[KMServer getDefaultServer] getConnectionPool] removeConnection:coordinator];
	return nil;
}

+(NSString*) getName
{
	return @"Quit";
}

// Because soft reboot under KittyMUD does not discriminate based on the state, we use this so we can remind players what they were doing after a soft reboot
-(void) softRebootMessage:(id)coordinator
{
	[coordinator sendMessage:@"Thanks for playing, hope we see you again soon."];
	[self processState:coordinator];
}

+(NSArray*)requirements
{
	return nil;
}

+(NSString*)menuLine
{
	return @"Exit the game.";
}

+(int) priority
{
	return 99;
}

@end
