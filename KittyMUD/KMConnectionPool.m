//
//  KMConnectionPool.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/12/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMConnectionPool.h"
#import "KMServer.h"
#import "KMBasicInterpreter.h"
#import "KMAccountNameState.h"
#import "KMString.h"
#import "KMState.h"

NSString* const KMConnectionPoolErrorDomain = @"KMConnectionPoolErrorDomain";

@implementation KMConnectionPool

-(id) init
{
	connections = [[NSMutableArray alloc] init];
	hooks = [[NSMutableArray alloc] init];
	readCallback = nil;
	return self;
}

-(void) checkOutputBuffers:(NSTimer *)timer
{
	for(KMConnectionCoordinator* coordinator in connections) {
		NSString* output = [coordinator outputBuffer];
		if([output length] > 0) {
			[coordinator sendMessage:output];
			[coordinator setOutputBuffer:@""];
			[coordinator setFlag:@"message-direct"];
			if(![coordinator isFlagSet:@"no-message"]) {
				[[coordinator currentState] softRebootMessage:coordinator];
			}
			[coordinator clearFlag:@"no-message"];
			[coordinator clearFlag:@"message-direct"];
		}
	}
}

static void ConnectionBaseCallback(CFSocketRef socket, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info)
{
	if(callbackType != kCFSocketDataCallBack)
		return;
	
	KMConnectionPool* pool = [[KMServer getDefaultServer] getConnectionPool];
	KMConnectionCoordinator* coordinator = (KMConnectionCoordinator*)info;
	NSString* inputString = [[NSString alloc] initWithData:(NSData*)data encoding:NSUTF8StringEncoding];
	if([inputString characterAtIndex:0] == '\x04') {
		NSLog(@"Encountered end-of-file from socket %d, closing connection...", CFSocketGetNative( socket ));
		[pool removeConnection:coordinator];
		return;
	}
	// This next line will remove new-lines and extra whitespace so when we compare it to the commands it will work
	inputString = [[inputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
	[coordinator setInputBuffer:inputString];
	[coordinator setLastReadTime:[NSDate date]];
	if([pool readCallback] != nil) {
		KMConnectionReadCallback cb = [pool readCallback];
		cb(coordinator);
	}
}

static NSString* greeting;


-(KMConnectionCoordinator*) newConnectionWithSocketHandle:(CFSocketNativeHandle) handle softReboot:(BOOL)softReboot {
	return [self newConnectionWithSocketHandle:handle softReboot:softReboot withName:nil];
}

-(KMConnectionCoordinator*) newConnectionWithSocketHandle:(CFSocketNativeHandle) handle softReboot:(BOOL)softReboot withName:(NSString*)name
{
	if(!greeting) {
		NSFileHandle* greetingf = [NSFileHandle fileHandleForReadingAtPath:[@"$(DataDir)/greeting.xml" replaceAllVariables]];
		if(!greetingf) {
			greeting = @"`RWelcome to $(Name).\n\rPlease enter your account name:";
		} else {
			NSXMLDocument* greetingxml = [[NSXMLDocument alloc] initWithData:[greetingf readDataToEndOfFile] options:0 error:NULL];
			NSXMLElement* greetingtext = [[[greetingxml rootElement] elementsForName:@"text"] objectAtIndex:0];
			greeting = [greetingtext stringValue];
		}
	}
	KMConnectionCoordinator* coordinator;
	if(!softReboot) {
		coordinator = [[KMConnectionCoordinator alloc] init];
	} else {
		coordinator = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSString stringWithFormat:@"$(BundleDir)/tmp/%@.arc",name] replaceAllVariables]];
	}

	CFSocketContext newContext = { 0, coordinator, NULL, NULL, NULL };
	CFSocketRef newSocket = CFSocketCreateWithNative(kCFAllocatorDefault, handle, kCFSocketDataCallBack, (CFSocketCallBack)&ConnectionBaseCallback, &newContext);
	if(newSocket == NULL) {
		NSLog(@"[WARNING] Error creating new socket, not adding to pool and closing...");
		close( handle );
		return nil;
	}
	[coordinator setSocket:newSocket];
	[connections addObject:coordinator];
	CFRunLoopSourceRef connRLS = CFSocketCreateRunLoopSource(kCFAllocatorDefault, newSocket, 0);
	CFRunLoopRef rl = CFRunLoopGetCurrent();
	CFRunLoopAddSource(rl, connRLS, kCFRunLoopCommonModes);
	CFRelease(connRLS);
	if(!softReboot) {
		[coordinator sendMessageToBuffer:greeting];
		[coordinator setInterpreter:[[KMBasicInterpreter alloc] init]];
		[coordinator setCurrentState:[[KMAccountNameState alloc] init]];
	} else {
		[[coordinator currentState] softRebootMessage:coordinator];
	}
	return coordinator;
}


-(void) addHook:(id<KMWriteHook>)hook
{
	if(![hooks containsObject:hook])
		[hooks addObject:hook];
}

-(void) removeHook:(id<KMWriteHook>)hook
{
	if([hooks containsObject:hook])
		[hooks removeObjectIdenticalTo:hook];
}

-(void) writeToAllConnections:(NSString*)message
{
	for(KMConnectionCoordinator* coordinator in connections) {
		[coordinator sendMessage:message];
	}
}

-(void) removeConnection:(KMConnectionCoordinator*)connection
{
	if (![connections containsObject:connection]) {
		return;
	}
	[connections removeObjectIdenticalTo:connection];
	if([connection getSocket]) {
		int native = CFSocketGetNative([connection getSocket]);
		CFSocketInvalidate([connection getSocket]);
		CFRelease([connection getSocket]);
		NSLog(@"Closing socket %d.", native);
	}
}

@synthesize connections;
@synthesize hooks;
@synthesize readCallback;
@end
