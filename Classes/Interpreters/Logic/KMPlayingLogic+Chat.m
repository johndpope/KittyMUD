//
//  KMPlayingLogic+Chat.m
//  KittyMUD
//
//  Created by Michael Tindal on 1/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KMPlayingLogic+Chat.h"
#import "KMCommandInterpreter.h"
#import "KMChatEngine.h"

@implementation KMPlayingLogic (ChatLogic)

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
@end
