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
CIMPL(say,say:message:,@"message",@"'",nil,1) message:(NSString *)message {
    KMChatEngine* chat = [KMChatEngine chatEngine];
    if(![chat.chatChannels objectForKey:@"say"]) {
        [chat addChatChannel:@"say" ofType:KMChatSay withFlags:nil];
    }
    
    [chat sendChatMessage:message toChannel:@"say" fromCoordinator:coordinator];
}

// yell

CHELP(yell,@"Sends a message to a broad area surrounding your character.",nil)
CIMPL(yell,yell:message:,@"message",nil,nil,1) message:(NSString *)message {
    KMChatEngine* chat = [KMChatEngine chatEngine];
    if(![chat.chatChannels objectForKey:@"yell"]) {
        [chat addChatChannel:@"yell" ofType:KMChatYell withFlags:nil];
    }
    
    [chat sendChatMessage:message toChannel:@"yell" fromCoordinator:coordinator];
}


@end
