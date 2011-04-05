//
//  KMPlayingLogic+Chat.m
//  KittyMUD
//
//  Created by Michael Tindal on 1/8/11.
//  Copyright 2011 Michael Tindal. All rights reserved.
//

#import "KMPlayingLogic+Social.h"
#import "KMCommandInterpreter.h"
#import "KMChatEngine.h"
#import "KMInfoDisplay.h"
#import "KMServer.h"
#import "KMCharacter.h"
#import "KMClass.h"
#import "KMStat.h"

@implementation KMPlayingLogic (SocialLogic)

// say

CHELP(say,@"Sends a message to the immediate area surrounding your character.",nil)
CIMPL(say,say:message:,nil,@"'",nil,1) message:(NSString *)message {
    KMChatEngine* chat = [KMChatEngine chatEngine];
    if(![chat.chatChannels objectForKey:@"say"]) {
        [chat addChatChannel:@"say" ofType:KMChatSay withFlags:nil];
    }
    
    [chat sendChatMessage:message toChannel:@"say" fromCoordinator:coordinator];
}

// yell

CHELP(yell,@"Sends a message to a broad area surrounding your character.",nil)
CIMPL(yell,yell:message:,nil,nil,nil,1) message:(NSString *)message {
    KMChatEngine* chat = [KMChatEngine chatEngine];
    if(![chat.chatChannels objectForKey:@"yell"]) {
        [chat addChatChannel:@"yell" ofType:KMChatYell withFlags:nil];
    }
    
    [chat sendChatMessage:message toChannel:@"yell" fromCoordinator:coordinator];
}

// whisper
CHELP(whisper,@"Sends a whisper to another player, no matter where they are located in the world.",nil)
CIMPL(whisper,whisper:target:message:,nil,@"t",nil,1) target:(NSString*)target message:(NSString*)message {
    if(![KMConnectionCoordinator getCoordinatorForCharacterWithName:target]) {
        [coordinator sendMessageToBuffer:@"No character by that name exists."];
        return;
    }
    KMChatEngine* chat = [KMChatEngine chatEngine];
    NSString* channelName = [NSString stringWithFormat:@"w%@",target];
    if(![chat.chatChannels objectForKey:channelName]) {
        [chat addChatChannel:target ofType:KMChatWhisper withFlags:nil];
    }
    [chat sendChatMessage:message toChannel:channelName fromCoordinator:coordinator];
}

// reply
CHELP(reply,@"Replies to a whisper you have just received.",nil)
CIMPL(reply, reply:message:, nil, @"tt", nil, 1) message:(NSString *)message {
    NSString* target = [coordinator valueForKeyPath:@"properties.reply-target"];
    if(!target) {
        [coordinator sendMessageToBuffer:@"No reply target."];
        return;
    }
    if(![KMConnectionCoordinator getCoordinatorForCharacterWithName:target]) {
        [coordinator sendMessageToBuffer:@"No character by that name exists."];
        return;
    }
    KMChatEngine* chat = [KMChatEngine chatEngine];
    NSString* channelName = [NSString stringWithFormat:@"w%@",target];
    if(![chat.chatChannels objectForKey:channelName]) {
        [chat addChatChannel:target ofType:KMChatWhisper withFlags:nil];
    }
    [chat sendChatMessage:message toChannel:channelName fromCoordinator:coordinator];
}

// ooc
CHELP(ooc, @"Sends a message to the global OOC chat channel.", nil)
CIMPL(ooc, ooc:message:, nil, nil, nil, 1) message:(NSString *)message {
    KMChatEngine* chat = [KMChatEngine chatEngine];
    if(![chat.chatChannels objectForKey:@"OOC"]) {
        [chat addChatChannel:@"OOC" ofType:KMChatGlobal withFlags:nil];
    }
    
    [chat sendChatMessage:message toChannel:@"OOC" fromCoordinator:coordinator];
}

// who
CHELP(who, @"Shows you who is currently online.", nil)
CIMPL(who, who:, nil, nil, nil, 1) {
    KMInfoDisplay* whoDisplay = [[KMInfoDisplay alloc] init];
    NSArray* coordinators = [[[[KMServer defaultServer] connectionPool] connections] sortedArrayUsingComparator:^NSComparisonResult(id obj1,id obj2) {
        KMCharacter* ch1 = [obj1 valueForKeyPath:@"character"];
        KMCharacter* ch2 = [obj2 valueForKeyPath:@"character"];
        if(ch1 && !ch2) {
            return NSOrderedAscending;
        } else if(ch2 && !ch1) {
            return NSOrderedDescending;
        }
        if([ch1.stats findStatWithPath:@"slvl"] && ![ch2.stats findStatWithPath:@"slvl"])
            return NSOrderedAscending;
        else if(![ch1.stats findStatWithPath:@"slvl"] && [ch2.stats findStatWithPath:@"slvl"])
            return NSOrderedDescending;
        else if([ch1.stats findStatWithPath:@"slvl"] && [ch2.stats findStatWithPath:@"slvl"]) {
            int slvl1 = [ch1.stats getValueOfChildAtPath:@"slvl"];
            int slvl2 = [ch2.stats getValueOfChildAtPath:@"slvl"];
            if(slvl1 > slvl2)
                return NSOrderedAscending;
            else if(slvl1 == slvl2)
                return NSOrderedSame;
            else
                return NSOrderedDescending;
        } else {
            int lvl1 = [ch1.stats getValueOfChildAtPath:@"level"];
            int lvl2 = [ch2.stats getValueOfChildAtPath:@"level"];
            if(lvl1 > lvl2)
                return NSOrderedAscending;
            else if(lvl1 == lvl2)
                return NSOrderedSame;
            else
                return NSOrderedDescending;
        }
    }];
    int online = 0;
    [whoDisplay appendSeperator];
    for(KMConnectionCoordinator* c in coordinators) {
        id<KMState> state = [c valueForKeyPath:@"properties.current-state"];
        if(![NSStringFromClass([state class]) isEqualToString:@"KMPlayingState"])
            continue;
        NSString* invis = @"";
        KMCharacter* ch = [c valueForKeyPath:@"character"];
        if([c isFlagSet:@"invisible"] && ch && [ch.stats getValueOfChildAtPath:@"slvl"] > 0) {
            KMCharacter* mch = [coordinator valueForKeyPath:@"character"];
            if([mch.stats getValueOfChildAtPath:@"slvl"]) {
                KMCharacter* och = [c valueForKeyPath:@"character"];
                int mslvl = [mch.stats getValueOfChildAtPath:@"slvl"];
                int oslvl = [och.stats getValueOfChildAtPath:@"slvl"];
                if(mslvl < oslvl)
                    continue;
                else {
                    invis = @"`C(`cInvis`C)";
                }
            } else {
                continue;
            }
        }
        KMClass* cl = [KMClass getClassByName:[ch valueForKeyPath:@"properties.class"]];
        NSString* clan = @"";
        if([ch valueForKeyPath:@"properties.clan"]) {
            clan = [NSString stringWithFormat:@"`G<%@`G>",[ch valueForKeyPath:@"properties.clan"]];
        }
        NSUInteger level = [ch.stats getValueOfChildAtPath:@"level"];
        NSString* special = [ch valueForKeyPath:@"properties.special-rank"];
        if(level < 30 && !special)
            [whoDisplay appendLine:[NSString stringWithFormat:@"`w[`g%03d`w(`c%@`w)] `y%@ %@ %@",level,cl.abbreviation,[ch valueForKeyPath:@"properties.name"],clan,invis]];
        else {
            [whoDisplay appendLine:[NSString stringWithFormat:@"`w[`g%3@`w(`c%@`w)] `y%@ %@ %@",special,cl.abbreviation,[ch valueForKeyPath:@"properties.name"],clan,invis]];
        }
        online++;
    }
    [whoDisplay appendSeperator];
    [whoDisplay appendLine:[NSString stringWithFormat:@"%d online.",online]];
    [whoDisplay appendSeperator];
    [coordinator sendMessageToBuffer:[whoDisplay finalOutput]];
}
@end
