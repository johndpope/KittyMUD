//
//  KMConnectionPool.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/12/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMConnectionCoordinator.h"
#import "KMWriteHook.h"
#import "KMObject.h"
#import "KMState.h"

NSString* const KMConnectionPoolErrorDomain;

typedef enum {
	kKMConnectionPoolCouldNotCreateSocket = 1,
} KMConnectionPoolErrorCodes;

typedef void (^KMConnectionReadCallback) (id);

@interface  KMConnectionPool  : KMObject {
	NSMutableArray* connections;
	NSMutableArray* hooks;
	KMConnectionReadCallback readCallback;
	NSString* greeting;
	id<KMState> defaultState;
}

-(id) init;

-(KMConnectionCoordinator*) newConnectionWithSocketHandle:(CFSocketNativeHandle) handle softReboot:(BOOL)softReboot;

-(KMConnectionCoordinator*) newConnectionWithSocketHandle:(CFSocketNativeHandle)handle softReboot:(BOOL)softReboot withName:(NSString*)name;

-(void) writeToAllConnections:(NSString*)message;

-(void) removeConnection:(KMConnectionCoordinator*)connection;

-(void) checkOutputBuffers:(NSTimer*)timer;

-(void) addHook:(id<KMWriteHook>)hook;

-(void) removeHook:(id<KMWriteHook>)hook;

@property (retain) NSMutableArray* connections;
@property (retain) NSMutableArray* hooks;
@property (copy) KMConnectionReadCallback readCallback;
@property (retain) NSString* greeting;
@property (retain) id<KMState> defaultState;
@end
