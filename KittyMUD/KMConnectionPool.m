//
//  KMConnectionPool.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "KMConnectionPool.h"
#import "KMServer.h"

@implementation KMWriteHook

-(KMWriteHook*) initializeWithTarget:(id)itarget andSelector:(SEL)iselector
{
	self = [super init];
	if(self)
	{
		[self setTarget:itarget];
		[self setSelector:iselector];
	}
	return self;
}

@synthesize target;
@synthesize selector;
@end

NSString* const KMConnectionPoolErrorDomain = @"KMConnectionPoolErrorDomain";

@implementation KMConnectionPool

-(id) init
{
	connections = [[NSMutableArray alloc] init];
	hooks = [[NSMutableArray alloc] init];
	return self;
}

-(void) checkOutputBuffers:(NSTimer *)timer
{
	for(KMConnectionCoordinator* coordinator in connections) {
		NSString* output = [coordinator outputBuffer];
		if([output length] > 0) {
			[coordinator sendMessage:output];
			[coordinator setOutputBuffer:@""];
			/*if([[[coordinator state] name] isEqualToString:@"PLAYING"]) {
				[[[coordinator engineManager] getEngine:@"PROMPT"] displayPrompt:coordinator];
			}*/
		}
	}
}

static void ConnectionBaseCallback(CFSocketRef socket, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info)
{
	if(callbackType != kCFSocketDataCallBack)
		return;
	
	KMConnectionPool* pool = [[KMServer getDefaultServer] getConnectionPool];
	KMConnectionCoordinator* coordinator = (KMConnectionCoordinator*)info;
	NSString* inputString = [[NSString alloc] initWithData:(NSData*)data encoding:NSASCIIStringEncoding];
	if([inputString characterAtIndex:0] == '\x04') {
		NSLog(@"Encountered end-of-file from socket %d, closing connection...", CFSocketGetNative( socket ));
		[pool removeConnection:coordinator];
		return;
	}
	// This next line will remove new-lines and extra whitespace so when we compare it to the commands it will work
	inputString = [[inputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
	NSLog(inputString);
	[coordinator setInputBuffer:inputString];
	[coordinator setLastReadTime:[NSDate date]];
	if([[coordinator getInputBuffer] isEqualToString:@"testwriteall"])
		[pool writeToAllConnections:@"Test Write All (whitespace trim)"];
}

-(BOOL) newConnectionWithSocketHandle:(CFSocketNativeHandle) handle
{
	KMConnectionCoordinator* coordinator = [[KMConnectionCoordinator alloc] init];
	CFSocketContext newContext = { 0, coordinator, NULL, NULL, NULL };
	CFSocketRef newSocket = CFSocketCreateWithNative(kCFAllocatorDefault, handle, kCFSocketDataCallBack, (CFSocketCallBack)&ConnectionBaseCallback, &newContext);
	if(newSocket == NULL) {
		NSLog(@"[WARNING] Error creating new socket, not adding to pool and closing...");
		close( handle );
		return NO;
	}
	[coordinator setSocket:newSocket];
	[connections addObject:coordinator];
	CFRunLoopSourceRef connRLS = CFSocketCreateRunLoopSource(kCFAllocatorDefault, newSocket, 0);
	CFRunLoopRef rl = CFRunLoopGetCurrent();
	CFRunLoopAddSource(rl, connRLS, kCFRunLoopCommonModes);
	CFRelease(connRLS);
	[coordinator sendMessageToBuffer:@"`RWelcome to $(Name)."];
	[coordinator sendMessage:@"Test new-line without buffer"];
	return YES;
}


-(void) addHook:(KMWriteHook*)hook
{
	if(![hooks containsObject:hook])
		[hooks addObject:hook];
}

-(void) removeHook:(KMWriteHook*)hook
{
	if([hooks containsObject:hook])
		[hooks removeObjectIdenticalTo:hook];
}

-(void) writeToAllConnections:(NSString*)message
{
	for(KMConnectionCoordinator* coordinator in connections) {
		[coordinator sendMessageToBuffer:message];
	}
}

-(void) removeConnection:(KMConnectionCoordinator*)connection
{
	if (![connections containsObject:connection]) {
		return;
	}
	[connections removeObjectIdenticalTo:connection];
	if([connection getSocket]) {
		CFSocketInvalidate([connection getSocket]);
		CFRelease([connection getSocket]);
	}
}
@synthesize connections;
@synthesize hooks;
@end
