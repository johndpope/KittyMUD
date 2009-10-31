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
#import "NSString+KMAdditions.h"
#import "KMState.h"
#import "KMAccountNameState.h"

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


-(KMConnectionCoordinator*) newConnectionWithSocketHandle:(CFSocketNativeHandle) handle softReboot:(BOOL)softReboot {
	return [self newConnectionWithSocketHandle:handle softReboot:softReboot withName:nil];
}

-(KMConnectionCoordinator*) newConnectionWithSocketHandle:(CFSocketNativeHandle) handle softReboot:(BOOL)softReboot withName:(NSString*)name
{
	if(!greeting) {
		greeting = @"`RWelcome to $(Name).\n\rPlease enter your account name:";
	}
	if(!defaultState) {
		defaultState = [KMAccountNameState class];
	}
	KMConnectionCoordinator* coordinator;
	if(!softReboot) {
		coordinator = [[KMConnectionCoordinator alloc] init];
	} else {
		coordinator = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSString stringWithFormat:@"$(BundleDir)/tmp/%@.arc",name] replaceAllVariables]];
	}
	
	if([coordinator createSocketWithHandle:handle andCallback:(CFSocketCallBack)&ConnectionBaseCallback])
		[connections addObject:coordinator];
	if(!softReboot) {
		[coordinator sendMessageToBuffer:greeting];
		[coordinator setInterpreter:[[KMBasicInterpreter alloc] init]];
		[coordinator setCurrentState:[[defaultState alloc] init]];
	} else {
		[[coordinator currentState] softRebootMessage:coordinator];
		[coordinator setFlag:@"no-message"];
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
		[connection releaseSocket];
		NSLog(@"Closing socket %d.", native);
	}
}

@synthesize connections;
@synthesize hooks;
@synthesize readCallback;
@synthesize greeting;
@synthesize defaultState;
@end
