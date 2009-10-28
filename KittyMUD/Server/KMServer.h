//
//  KMServer.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/12/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import "KMConnectionPool.h"

NSString* const KMServerErrorDomain;

typedef enum {
    kKMServerCouldNotBindToAddress = 1,
    kKMServerNoSocketsAvailable = 2,
} KMServerErrorCode;

@interface KMServer : NSObject {
	@private
	CFSocketRef serverSocket;
	int currentPoolId;
	KMConnectionPool* connectionPool;
	BOOL isRunning;
}

+(KMServer*)getDefaultServer;

-(id) init;

-(KMConnectionPool*) getConnectionPool;

-(BOOL) initializeServerWithPort:(int)port error:(NSError**)error;

-(void) shutdown;

-(void) softReboot;

-(void) softRebootRecovery:(CFSocketNativeHandle)socketHandle;

@property CFSocketRef serverSocket;
@property int currentPoolId;
@property (retain,getter=getConnectionPool) KMConnectionPool* connectionPool;
@property BOOL isRunning;
@end
