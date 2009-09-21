//
//  KMChooseCharacterState.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/21/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMChooseCharacterState.h"


@implementation KMChooseCharacterState

-(id<KMState>) processState:(id)coordinator
{
	return nil;
}

-(NSString*) getName
{
	return @"ChooseCharacter";
}

// Because soft reboot under KittyMUD does not discriminate based on the state, we use this so we can remind players what they were doing after a soft reboot
-(void) softRebootMessage:(id)coordinator
{
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
