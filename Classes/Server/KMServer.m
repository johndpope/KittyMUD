//
//  KMServer.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/12/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as 
// published by the Free Software Foundation; either version 3 of 
// the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
//

#import "KMServer.h"
#import "NSString+KMAdditions.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

NSString* const KMServerErrorDomain = @"KMServerErrorDomain";
KMServer* defaultServerBase;

static void ServerBaseCallout(CFSocketRef __unused socket, CFSocketCallBackType callbackType, CFDataRef __unused address, const void *data, void *info)
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
	serverSocket = CFSocketCreate(kCFAllocatorDefault, PF_INET6, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, (CFSocketCallBack)&ServerBaseCallout, &serverContext);
	
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

	struct sockaddr_in6 serverAddr;
	
	memset(&serverAddr, 0, sizeof(serverAddr));
	serverAddr.sin6_len = sizeof(serverAddr);
	serverAddr.sin6_family = AF_INET6;
	serverAddr.sin6_port = htons((__uint16_t)port);
	serverAddr.sin6_addr = in6addr_any;
	
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
		[coordinator clearFlag:@"softreboot-displayed"];
		[coordinator setOutputBuffer:@""];

        [coordinator saveToXML:[@"$(BundleDir)/tmp" replaceAllVariables] withState:YES];
		[softRebootFile writeData:[[NSString stringWithFormat:@"%d %@\n\r",CFSocketGetNative([coordinator getSocket]),[coordinator valueForKeyPath:@"properties.name"]] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	[softRebootFile closeFile];
	char const*__attribute__((objc_gc(strong))) executable_name = [[@"$(BundleDir)/$(ExeName)" replaceAllVariables] cStringUsingEncoding:NSUTF8StringEncoding];
	execl(executable_name, executable_name, "softreboot", [[NSString stringWithFormat:@"%d",CFSocketGetNative(serverSocket)] cStringUsingEncoding:NSUTF8StringEncoding], (char*)NULL);
	OCLog(@"kittymud",info,@"Error running execl, soft reboot aborted.");
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
        [[NSFileManager defaultManager] removeItemAtPath:[[NSString stringWithFormat:@"$(BundleDir)/tmp/%@.xml",[coordinator valueForKeyPath:@"properties.name"]] replaceAllVariables] error:NULL];
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
