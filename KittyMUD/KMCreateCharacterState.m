//
//  KMCreateCharacterState.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "KMCreateCharacterState.h"
#import "KMConnectionCoordinator.h"
#import "KMString.h"
#import "KMServer.h"
#import "KMCharacter.h"
#import "KMChooseRaceState.h"
#import "KMStatAllocationState.h"
#import "KMChooseJobState.h"
#import "KMConfirmStatAllocationState.h"
#import "KMWorkflow.h"
#import "KMPlayingState.h"

@implementation KMCreateCharacterState

-(id<KMState>) processState:(id)coordinator
{
	NSFileHandle* usedNamesFile = [NSFileHandle fileHandleForReadingAtPath:[@"$(UsedCharacterFile)" replaceAllVariables]];
	NSString* name = [coordinator getInputBuffer];
	if(usedNamesFile != nil)
	{
		NSArray* names = [[[NSString alloc] initWithData:[usedNamesFile readDataToEndOfFile] encoding:NSUTF8StringEncoding] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		NSPredicate* pred = [NSPredicate predicateWithFormat:@"self like[cd] %@", name];
		if([[names filteredArrayUsingPredicate:pred] count] > 0) {
			[coordinator sendMessageToBuffer:@"Character name already in use, please choose another."];
			[self softRebootMessage:coordinator];
			return self;
		}
	} else {
		[[NSFileManager defaultManager] createFileAtPath:[@"$(UsedCharacterFile)" replaceAllVariables] contents:nil attributes:nil];
	}
	[coordinator setFlag:[NSString stringWithFormat:@"new-character-%@",name]];
	[coordinator setFlag:@"has-character"];
	KMCharacter* character = [[KMCharacter alloc] initializeWithName:name];
	[[coordinator getCharacters] addObject:character];
	[[coordinator getProperties] setObject:character forKey:@"current-character"];
	KMWorkflow* wf = [KMWorkflow createWorkflowForSteps:[[KMChooseRaceState alloc] init],[[KMStatAllocationState alloc] init], [[KMPlayingState alloc] init], nil];
	[wf insertStep:[[KMChooseJobState alloc] init] before:[[KMPlayingState alloc] init]];
	[wf insertStep:[[KMConfirmStatAllocationState alloc] init] after:[[KMStatAllocationState alloc] init]];
	id<KMState> state = [wf startWorkflowAtStep:[[KMChooseRaceState alloc] init]];
	[coordinator setValue:wf forKeyPath:@"properties.current-workflow"];
	return state;
}

+(NSString*) getName
{
	return @"CreateCharacter";
}

// Because soft reboot under KittyMUD does not discriminate based on the state, we use this so we can remind players what they were doing after a soft reboot
-(void) softRebootMessage:(id)coordinator
{
	[coordinator sendMessageToBuffer:@"Please enter a name for your new character:"];
}

+(NSArray*)requirements
{
	return nil;
}

+(NSString*)menuLine
{
	return @"Create a new character";
}

+(int) priority
{
	return 1;
}
@end
