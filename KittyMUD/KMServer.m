//
//  KMServer.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/12/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMServer.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

NSString* const KMServerErrorDomain = @"KMServerErrorDomain";
static KMServer* defaultServerBase;

static void ServerBaseCallout(CFSocketRef socket, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info)
{
	if(callbackType != kCFSocketAcceptCallBack)
		return;
	
	KMServer* server = (KMServer*)info;
	CFSocketNativeHandle nativeHandle = *(CFSocketNativeHandle*)data;
	
	[[server getConnectionPool] newConnectionWithSocketHandle:nativeHandle];
}

@implementation KMServer

+(KMServer*) getDefaultServer
{
	return defaultServerBase;
}

+(void) initialize
{
	if(!defaultServerBase)
		defaultServerBase = [[KMServer alloc] init];
}

-(id) init
{
	connectionPool = [[KMConnectionPool alloc] init];
	return self;
}

-(KMConnectionPool*) getConnectionPool
{
	return connectionPool;
}

-(BOOL) initializeServerWithPort:(int)port error:(NSError**)error
{
	CFSocketContext serverContext = {0, self, NULL, NULL, NULL};
	serverSocket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, (CFSocketCallBack)&ServerBaseCallout, &serverContext);
	
	if (serverSocket == NULL) {
		if(error) *error = [[NSError alloc] initWithDomain:KMServerErrorDomain code:kKMServerNoSocketsAvailable userInfo:nil];
		return NO;
	}
	
	int yes = 1;
	int serverSocketNative = CFSocketGetNative(serverSocket);
	setsockopt(serverSocketNative, SOL_SOCKET, SO_REUSEADDR, (void*)&yes, sizeof(yes));
	
	struct sockaddr_in serverAddr;
	
	memset(&serverAddr, 0, sizeof(serverAddr));
	serverAddr.sin_len = sizeof(serverAddr);
	serverAddr.sin_family = AF_INET;
	serverAddr.sin_port = htons(port);
	serverAddr.sin_addr.s_addr = htonl(INADDR_ANY);
	
	NSData* serverAddrData = [NSData dataWithBytes:&serverAddr length:sizeof(serverAddr)];
	
	if(CFSocketSetAddress(serverSocket, (CFDataRef)serverAddrData) != kCFSocketSuccess)
	{
		if(error) *error = [[NSError alloc] initWithDomain:KMServerErrorDomain code:kKMServerCouldNotBindToAddress userInfo:nil];
		serverSocket = NULL;
		return NO;
	}
	CFRunLoopRef currentRunLoop = CFRunLoopGetCurrent();
	CFRunLoopSourceRef serverRunLoopSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, serverSocket, 0);
	CFRunLoopAddSource(currentRunLoop, serverRunLoopSource, kCFRunLoopCommonModes);
	CFRelease(serverRunLoopSource);
	[self setIsRunning:YES];
	return YES;
}

-(void) shutdown
{
	CFSocketNativeHandle serverNative = CFSocketGetNative(serverSocket);
	CFSocketInvalidate(serverSocket);
	close(serverNative);
	CFRelease(serverSocket);
	[self setIsRunning:NO];
}

@synthesize serverSocket;
@synthesize currentPoolId;
@synthesize connectionPool;
@synthesize isRunning;
@end
