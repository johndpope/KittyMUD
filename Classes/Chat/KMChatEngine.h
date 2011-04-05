//
//  KMChatEngine.h
//  KittyMUD
//
//  Created by Michael Tindal on 1/8/11.
//  Copyright 2011 Michael Tindal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMConnectionCoordinator.h"

typedef enum {
    KMChatSay,
    KMChatYell,
    KMChatWhisper,
    KMChatSector,
    KMChatGlobal
} KMChatType;

@interface KMChatEngine : NSObject {
    @private
    NSMutableDictionary* chatChannels;
}

+(KMChatEngine*) chatEngine;

-(void) sendChatMessage:(NSString*)message toChannel:(NSString*)channel fromCoordinator:(KMConnectionCoordinator*)coordinator;

-(void) addChatChannel:(NSString*)channel ofType:(KMChatType)type withFlags:(NSArray*)flags;

-(void) removeChatChannel:(NSString*)channel;

@property (retain,readonly) NSMutableDictionary* chatChannels;
@end
