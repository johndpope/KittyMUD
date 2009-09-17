//
//  KMConnectionCoordinator.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/12/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMState.h"

@interface KMConnectionCoordinator : NSObject {
	@private
	CFSocketRef socket;
	NSString* inputBuffer;
	NSString* outputBuffer;
	NSDate* lastReadTime;
	unsigned long long flagbase;
	NSMutableDictionary* flags;
	unsigned int currentbitpower;
	id<KMState> currentState;
}

-(id) init;

-(BOOL) isFlagSet:(NSString*)flagName;

-(void) setFlag:(NSString*)flagName;

-(void) clearFlag:(NSString*)flagName;

-(BOOL) sendMessage:(NSString*)message;

-(void) sendMessageToBuffer:(NSString*)message;

-(CFSocketRef) getSocket;

-(void) setSocket:(CFSocketRef)newSocket;

-(NSString*) getInputBuffer;

-(void) setInputBuffer:(NSString*)buffer;

-(void) setLastReadTime:(NSDate*)time;

-(NSDate*) getLastReadTime;

@property (getter=getSocket,setter=setSocket:) CFSocketRef socket;
@property (retain) NSString* outputBuffer;
@property (copy) id<KMState> currentState;
@end
