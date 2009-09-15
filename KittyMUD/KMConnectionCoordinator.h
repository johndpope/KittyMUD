//
//  KMConnectionCoordinator.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/12/09.
//  Copyright 2009 __Myfile://localhost/Users/mtindal/Documents/KittyMUD/KMConnectionPool.hCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface KMConnectionCoordinator : NSObject {
	@private
	CFSocketRef socket;
	NSString* inputBuffer;
	NSString* outputBuffer;
	NSDate* lastReadTime;
}

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
@end
