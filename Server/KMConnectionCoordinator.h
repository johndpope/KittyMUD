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
#import "KMObject.h"

@interface  KMConnectionCoordinator  : KMObject {
	@private
	CFSocketRef socket;
	NSString* inputBuffer;
	NSString* outputBuffer;
	NSDate* lastReadTime;
	NSMutableArray* characters;
}

-(id) init;

-(BOOL) sendMessage:(NSString*)message,...;

-(void) sendMessageToBuffer:(NSString*)message,...;

-(CFSocketRef) getSocket;

-(void) setSocket:(CFSocketRef)newSocket;

-(BOOL) createSocketWithHandle:(CFSocketNativeHandle)handle andCallback:(CFSocketCallBack)callback;

-(void) saveToXML:(NSString*)path;

-(void) loadFromXML:(NSString*)path;

// -(id) valueForUndefinedKey:(NSString *)key;

// -(void) setValue:(id)value forUndefinedKey:(NSString*)key;

-(void) releaseSocket;

@property (copy,getter=getLastReadTime) NSDate* lastReadTime;
@property (copy,getter=getInputBuffer) NSString* inputBuffer;
@property (getter=getSocket,setter=setSocket:) CFSocketRef socket;
@property (copy) NSString* outputBuffer;
@property (retain,readonly,getter=getCharacters) NSMutableArray* characters;
@end
