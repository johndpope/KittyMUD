//
//  KMServer.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/12/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMServer.h"
#import "NSString+KMAdditions.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

NSString* const KMServerErrorDomain = @"KMServerErrorDomain";
KMServer* defaultServerBase;

static void ServerBaseCallout(CFSocketRef socket, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info)
{
	if(callbackType != kCFSocketAcceptCallBack)
		return;
	
	KMServer* server = (KMServer*)info;
	CFSocketNativeHandle nativeHandle = *(CFSocketNativeHandle*)data;
	
	[[server getConnectionPool] newConnectionWithSocketHandle:nativeHandle softReboot:NO];
}

@implementation KMServer

+(KMServer*) getDefaultServer
{
	return defaultServerBase;
}

+(void) initialize
{
	defaultServerBase = [[KMServer alloc] init];
	[[NSGarbageCollector defaultCollector] disableCollectorForPointer:defaultServerBase];
}

-(id) init
{
	self = [super init];
	if(self) {
		connectionPool = [[KMConnectionPool alloc] init];
	}
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
	
	if(!error) {
		NSError* errorTmp = [[NSError alloc] init];
		error = &errorTmp;
	}
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

-(void) softReboot
{
	NSString* sr = [@"$(BundleDir)/tmp/sr" replaceAllVariables];
	[[NSFileManager defaultManager] createFileAtPath:sr contents:nil attributes:nil];
	NSFileHandle* softRebootFile = [NSFileHandle fileHandleForWritingAtPath:sr];
	for(KMConnectionCoordinator* coordinator in [connectionPool connections]) {
		[coordinator setFlag:@"soft-reboot"];
		[coordinator setOutputBuffer:@""];
		BOOL res = [NSKeyedArchiver archiveRootObject:coordinator toFile:[[NSString stringWithFormat:@"$(BundleDir)/tmp/%@.arc",[coordinator valueForKeyPath:@"properties.name"]] replaceAllVariables]];
		if(!res) {
			NSLog(@"Error archiving coordinator for account %@...", [coordinator valueForKeyPath:@"properties.name"]);
			continue;
		}
		[softRebootFile writeData:[[NSString stringWithFormat:@"%d %@\n\r",CFSocketGetNative([coordinator getSocket]),[coordinator valueForKeyPath:@"properties.name"]] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	[softRebootFile closeFile];
	char const*__attribute__((objc_gc(strong))) executable_name = [[@"$(BundleDir)/$(ExeName)" replaceAllVariables] cStringUsingEncoding:NSUTF8StringEncoding];
	execl(executable_name, executable_name, "softreboot", [[NSString stringWithFormat:@"%d",CFSocketGetNative(serverSocket)] cStringUsingEncoding:NSUTF8StringEncoding], (char*)NULL);
	NSLog(@"Error running execl, soft reboot aborted.");
}

-(void) softRebootRecovery:(CFSocketNativeHandle)socketHandle
{
	NSFileHandle* softRebootFile = [NSFileHandle fileHandleForReadingAtPath:[@"$(BundleDir)/tmp/sr" replaceAllVariables]];
	NSArray* lines = [[[NSString alloc] initWithData:[softRebootFile readDataToEndOfFile] encoding:NSUTF8StringEncoding] 
					  componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	CFSocketContext serverContext = {0, self, NULL, NULL, NULL};
	[self setServerSocket:CFSocketCreateWithNative(kCFAllocatorDefault, socketHandle, kCFSocketAcceptCallBack, (CFSocketCallBack)&ServerBaseCallout, (CFSocketContext const*)&serverContext)];
	for(NSString* line in lines) {
		if([line length] <= 0)
			continue;
		NSArray* components = [line componentsSeparatedByString:@" "];
		CFSocketNativeHandle cfs = [[components objectAtIndex:0] intValue];
		id coordinator = [connectionPool newConnectionWithSocketHandle:cfs softReboot:YES withName:[components objectAtIndex:1]];
		[coordinator clearFlag:@"soft-reboot"];
		[[NSFileManager defaultManager] removeItemAtPath:[[NSString stringWithFormat:@"$(BundleDir)/tmp/%@.arc",[coordinator valueForKeyPath:@"properties.name"]] replaceAllVariables] error:NULL];
	}
	CFRunLoopRef currentRunLoop = CFRunLoopGetCurrent();
	CFRunLoopSourceRef serverRunLoopSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, serverSocket, 0);
	CFRunLoopAddSource(currentRunLoop, serverRunLoopSource, kCFRunLoopCommonModes);
	CFRelease(serverRunLoopSource);
	[connectionPool writeToAllConnections:@"Soft reboot completed."];
	[self setIsRunning:YES];
	[[NSFileManager defaultManager] removeItemAtPath:[@"$(BundleDir)/tmp/sr" replaceAllVariables] error:NULL];
}

@synthesize serverSocket;
@synthesize currentPoolId;
@synthesize connectionPool;
@synthesize isRunning;
@end
