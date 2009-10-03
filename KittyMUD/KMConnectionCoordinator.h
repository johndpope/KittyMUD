//
//  KMConnectionCoordinator.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/12/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMState.h"
#import "KMInterpreter.h"

@interface KMConnectionCoordinator : NSObject {
	@private
	CFSocketRef socket;
	NSString* inputBuffer;
	NSString* outputBuffer;
	NSDate* lastReadTime;
	NSMutableArray* flagbase;
	NSMutableDictionary* flags;
	unsigned int currentbitpower;
	id<KMState> currentState;
	id<KMInterpreter> interpreter;
	NSMutableDictionary* properties;
	NSMutableArray* characters;
}

-(id) init;

-(BOOL) isFlagSet:(NSString*)flagName;

-(void) setFlag:(NSString*)flagName;

-(void) clearFlag:(NSString*)flagName;

-(BOOL) sendMessage:(NSString*)message;

-(void) sendMessageToBuffer:(NSString*)message;

-(CFSocketRef) getSocket;

-(void) setSocket:(CFSocketRef)newSocket;

@property (copy,getter=getLastReadTime) NSDate* lastReadTime;
@property (copy,getter=getInputBuffer) NSString* inputBuffer;
@property (getter=getSocket,setter=setSocket:) CFSocketRef socket;
@property (copy) NSString* outputBuffer;
@property (retain) id<KMState> currentState;
@property (retain) id<KMInterpreter> interpreter;
@property (retain,readonly,getter=getProperties) NSMutableDictionary* properties;
@property (retain,readonly,getter=getCharacters) NSMutableArray* characters;
@property (retain,readonly) NSMutableArray* flagbase;
@property (retain,readonly) NSMutableDictionary* flags;
@property (readonly) unsigned int currentbitpower;
@end

@interface KMConnectionCoordinator ()

-(void) debugPrintFlagStatus;

@end
