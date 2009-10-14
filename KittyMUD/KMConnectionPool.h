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

NSString* const KMConnectionPoolErrorDomain;

typedef enum {
	kKMConnectionPoolCouldNotCreateSocket = 1,
} KMConnectionPoolErrorCodes;

typedef void (^KMConnectionReadCallback) (id);

@interface KMConnectionPool : NSObject {
	NSMutableArray* connections;
	NSMutableArray* hooks;
	KMConnectionReadCallback readCallback;
}

-(id) init;

-(KMConnectionCoordinator*) newConnectionWithSocketHandle:(CFSocketNativeHandle) handle softReboot:(BOOL)softReboot;

-(void) writeToAllConnections:(NSString*)message;

-(void) removeConnection:(KMConnectionCoordinator*)connection;

-(void) checkOutputBuffers:(NSTimer*)timer;

-(void) addHook:(id<KMWriteHook>)hook;

-(void) removeHook:(id<KMWriteHook>)hook;

@property (retain) NSMutableArray* connections;
@property (retain) NSMutableArray* hooks;
@property (copy) KMConnectionReadCallback readCallback;
@end
