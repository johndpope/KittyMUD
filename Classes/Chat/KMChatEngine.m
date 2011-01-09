//
//  KMChatEngine.m
//  KittyMUD
//
//  Created by Michael Tindal on 1/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KMChatEngine.h"
#import "KMServer.h"
#import "KMState.h"
#import "KMRoom.h"
#import "KMCharacter.h"

@interface KMChatChannel : NSObject {
    NSString* name;
    NSArray* flags;
    KMChatType type;
}

-(id) initWithName:(NSString*)n type:(KMChatType)t flags:(NSArray*)flags;

-(NSArray*) getRecipientsOfMessageFrom:(KMConnectionCoordinator*)coordinator;

@property (copy) NSString* name;
@property (retain) NSArray* flags;
@property (assign) KMChatType type;

@end

@implementation KMChatChannel

-(id) initWithName:(NSString *)n type:(KMChatType)t flags:(NSArray *)f {
    if((self = [super init])) {
        name = [n copy];
        type = t;
        flags = f;
    }
    return self;
}

-(NSArray*) getRecipientsOfMessageFrom:(KMConnectionCoordinator *)coordinator {
    NSMutableArray* recipients = [NSMutableArray array];
    NSUInteger range = type == KMChatSay ? 2 : 5;
    NSArray* allCoordinators = [[[KMServer defaultServer] connectionPool] connections];
    NSArray* allRooms = [KMRoom getAllRooms];
    NSPredicate* roomPred;
    NSMutableArray* rooms = [NSMutableArray array];
    KMRoom* currentRoom;
    switch(type) {
        case KMChatWhisper:
            [recipients addObject:[KMConnectionCoordinator getCoordinatorForCharacterWithName:[self.name substringFromIndex:1]]];
            [recipients addObject:coordinator];
            break;
        case KMChatGlobal:
            recipients = [NSMutableArray arrayWithArray:allCoordinators];
            break;
        case KMChatSay:
        case KMChatYell:
            [rooms addObject:[coordinator valueForKeyPath:@"character.room"]];
            NSMutableArray* tmpRooms = [NSMutableArray arrayWithArray:rooms];
            for(NSUInteger i = 0; i < range; i++) {
                for(KMRoom* currentRoom in rooms) {
                    for(KMExitInfo* exit in currentRoom.exitInfo) {
                        if([tmpRooms containsObject:[KMRoom getRoomByName:exit.destination]])
                            continue;
                        [tmpRooms addObject:[KMRoom getRoomByName:exit.destination]];
                    }
                }
                rooms = [NSMutableArray arrayWithArray:tmpRooms];
            }
            roomPred = [NSPredicate predicateWithFormat:@"self.character.room in %@",rooms];
            recipients = [NSMutableArray arrayWithArray:[allCoordinators filteredArrayUsingPredicate:roomPred]];
            break;
        case KMChatSector:
            currentRoom = [coordinator valueForKeyPath:@"character.room"];
            roomPred = [NSPredicate predicateWithFormat:@"self.sector like[cd] %@",currentRoom.sector];
            rooms = [NSMutableArray arrayWithArray:[allRooms filteredArrayUsingPredicate:roomPred]];
            roomPred = [NSPredicate predicateWithFormat:@"self.character.room in %@",rooms];
            recipients = [NSMutableArray arrayWithArray:[allCoordinators filteredArrayUsingPredicate:roomPred]];
            break;
    }
    return recipients;
}

@end
static KMChatEngine* __KMChatEngine;

@implementation KMChatEngine

+(void) initialize {
    __KMChatEngine = [[KMChatEngine alloc] init];
}

+(KMChatEngine*) chatEngine {
    return __KMChatEngine;
}

- (id)init {
    if ((self = [super init])) {
        chatChannels = [NSMutableDictionary dictionary];
    }
    
    return self;
}

-(void) sendChatMessage:(NSString *)message toChannel:(NSString *)channel fromCoordinator:(KMConnectionCoordinator *)coordinator {
    KMChatChannel* _channel = [chatChannels objectForKey:channel];
    if(!_channel)
        return;
    NSArray* coordinators = [_channel getRecipientsOfMessageFrom:coordinator];
    NSMutableArray* recipients = [NSMutableArray arrayWithArray:coordinators];
    // this is where we validate flags to make sure coordinators have permission to view this channel
    for(KMConnectionCoordinator* coord in coordinators) {
        KMCharacter* pc = [coord valueForKeyPath:@"properties.current-character"];
        for(NSString* flag in _channel.flags) {
            if(![coord isFlagSet:flag] && ![pc isFlagSet:flag])
                [recipients removeObject:coord];
        }
    }
    NSString* _message;
    KMCharacter* character = [coordinator valueForKeyPath:@"character"];
    NSString* characterName = [[character valueForKeyPath:@"properties.name"] capitalizedString];
    switch(_channel.type) {
        case KMChatWhisper:
            _message = [NSString stringWithFormat:@"\n\r`m%@ whispers: %@",characterName,message];
            break;
        case KMChatGlobal:
            _message = [NSString stringWithFormat:@"\n\r`y[`w%@(`c%@`w)`y] %@",characterName,channel,message];
            break;
        case KMChatSector:
            _message = [NSString stringWithFormat:@"\n\r`c[`w%@`c] %@",characterName,message];
            break;
        case KMChatYell:
            _message = [NSString stringWithFormat:@"\n\r`r%@ yells: %@",characterName,message];
            break;
        case KMChatSay:
            _message = [NSString stringWithFormat:@"\n\r`w%@ says: %@",characterName,message];
            break;
    }
    [[[KMServer defaultServer] connectionPool] writeMessage:_message toConnections:recipients];
    if(_channel.type == KMChatWhisper) {
        for(KMConnectionCoordinator* coord in recipients) {
            [coord setValue:[coordinator valueForKeyPath:@"character.properties.name"] forKeyPath:@"properties.reply-target"];
        }
    }
}

-(void) addChatChannel:(NSString *)channel ofType:(KMChatType)type withFlags:(NSArray *)flags {
    NSString* key = channel;
    if(type == KMChatWhisper) {
        key = [NSString stringWithFormat:@"w%@",channel];
    }
    [chatChannels setObject:[[KMChatChannel alloc] initWithName:key type:type flags:flags] forKey:key];
}

-(void) removeChatChannel:(NSString *)channel {
    NSString* normalKey = [channel copy];
    NSString* whisperKey = [NSString stringWithFormat:@"w%@",channel];
    if([chatChannels objectForKey:normalKey])
        [chatChannels removeObjectForKey:normalKey];
    else
        [chatChannels removeObjectForKey:whisperKey];
}

@end
