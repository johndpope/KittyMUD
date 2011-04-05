//
//  KMPlayingLogic+Admin.m
//  KittyMUD
//
//  Created by Michael Tindal on 1/10/11.
//  Copyright 2011 Michael Tindal. All rights reserved.
//

#import "KMPlayingLogic+Admin.h"
#import "KMCommandInterpreter.h"
#import "KMChatEngine.h"
#import "KMInfoDisplay.h"
#import "KMServer.h"
#import "KMCharacter.h"
#import "KMClass.h"
#import "KMStat.h"

@implementation KMPlayingLogic (AdminLogic)

CHELP(setstat, @"Sets a stat on a character to a given value.", nil)
CIMPL(setstat, setstat:character:name:value:, nil, @"ss", @"admin", 1) character:(NSString *)character name:(NSString *)name value:(int)value {
    KMConnectionCoordinator* c = [KMConnectionCoordinator getCoordinatorForCharacterWithName:character];
    if(!c) {
        [coordinator sendMessageToBuffer:@"Unknown character."];
        return;
    }
    KMCharacter* ch = [c valueForKeyPath:@"character"];
    [ch.stats setValueOfChildAtPath:name withValue:value];
    [coordinator sendMessageToBuffer:@"Stat %@ on character %@ set to %d.",name,character,value];
}

CHELP(invis, @"Makes you invisible to who searches to anyone below your slvl.", nil)
CIMPL(invis, invis:, nil, nil, @"staff", 1) {
    if([coordinator isFlagSet:@"invisible"]) {
        [coordinator clearFlag:@"invisible"];
        [coordinator sendMessageToBuffer:@"You are now visible to everyone."];
    } else {
        [coordinator setFlag:@"invisible"];
        [coordinator sendMessageToBuffer:@"You are now invisible to everyone below your slvl."];
    }
}

CHELP(setflag, @"Sets a flag on a character (or account).", nil)
CIMPL(setflag, setflag:character:flag:, nil, nil, @"admin", 1) character:(NSString *)character flag:(NSString *)flag {
    BOOL forAccount = NO;
    if([character characterAtIndex:0] == '@') {
        forAccount = YES;
        character = [character substringFromIndex:1];
    }
    KMConnectionCoordinator* c = [KMConnectionCoordinator getCoordinatorForCharacterWithName:character];
    if(!c) {
        [coordinator sendMessageToBuffer:@"Unknown character."];
        return;
    }
    KMCharacter* ch = [c valueForKeyPath:@"character"];
    if(forAccount) {
        [c setFlag:flag];
        [coordinator sendMessageToBuffer:@"Set flag %@ on account %@.",flag,[c valueForKeyPath:@"properties.name"]];
    } else {
        [ch setFlag:flag];
        [coordinator sendMessageToBuffer:@"Set flag %@ on character %@.",flag,character];
    }
}

CHELP(clearflag, @"Clears a flag on a character (or account).", nil)
CIMPL(clearflag, clearflag:character:flag:, nil, nil, @"admin", 1) character:(NSString *)character flag:(NSString *)flag {
    BOOL forAccount = NO;
    if([character characterAtIndex:0] == '@') {
        forAccount = YES;
        character = [character substringFromIndex:1];
    }
    KMConnectionCoordinator* c = [KMConnectionCoordinator getCoordinatorForCharacterWithName:character];
    if(!c) {
        [coordinator sendMessageToBuffer:@"Unknown character."];
        return;
    }
    KMCharacter* ch = [c valueForKeyPath:@"character"];
    if(forAccount) {
        [c clearFlag:flag];
        [coordinator sendMessageToBuffer:@"Cleared flag %@ on account %@.",flag,[c valueForKeyPath:@"properties.name"]];
    } else {
        [ch clearFlag:flag];
        [coordinator sendMessageToBuffer:@"Cleared flag %@ on character %@.",flag,character];
    }
}

CHELP(isflagset, @"Sets a flag on a character (or account).", nil)
CIMPL(isflagset, isflagset:character:flag:, nil, nil, @"admin", 1) character:(NSString *)character flag:(NSString *)flag {
    BOOL forAccount = NO;
    if([character characterAtIndex:0] == '@') {
        forAccount = YES;
        character = [character substringFromIndex:1];
    }
    KMConnectionCoordinator* c = [KMConnectionCoordinator getCoordinatorForCharacterWithName:character];
    if(!c) {
        [coordinator sendMessageToBuffer:@"Unknown character."];
        return;
    }
    KMCharacter* ch = [c valueForKeyPath:@"character"];
    if(forAccount) {
        BOOL res = [c isFlagSet:flag];
        [coordinator sendMessageToBuffer:@"Flag %@ on account %@ is %@.",flag,[c valueForKeyPath:@"properties.name"],res ? @"set" : @"cleared"];
    } else {
        BOOL res = [ch isFlagSet:flag];
        [coordinator sendMessageToBuffer:@"Flag %@ on character %@ is %@.",flag,character,res ? @"set" : @"cleared"];
    }
}

@end
