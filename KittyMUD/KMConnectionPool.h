//
//  KMConnectionPool.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMConnectionCoordinator.h"

NSString* const KMConnectionPoolErrorDomain;

typedef enum {
	kKMConnectionPoolCouldNotCreateSocket = 1,
} KMConnectionPoolErrorCodes;

typedef void (*KMConnectionReadCallback) (id,id);

@interface KMWriteHook : NSObject {
	id target;
	SEL selector;
}

-(KMWriteHook*) initializeWithTarget:(id)itarget andSelector:(SEL)iselector;

@property (retain) id target;
@property SEL selector;
@end

@interface KMConnectionPool : NSObject {
	NSMutableArray* connections;
	NSMutableArray* hooks;
}

-(id) init;

-(BOOL) newConnectionWithSocketHandle:(CFSocketNativeHandle) handle;

-(void) writeToAllConnections:(NSString*)message;

-(void) removeConnection:(KMConnectionCoordinator*)connection;

-(void) checkOutputBuffers:(NSTimer*)timer;

-(void) addHook:(KMWriteHook*)hook;

-(void) removeHook:(KMWriteHook*)hook;

@property (retain) NSMutableArray* connections;
@property (retain) NSMutableArray* hooks;
@end
