//
//  KMConnectionCoordinator.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/12/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMConnectionCoordinator.h"
#import "KMServer.h"

/*
 * This class represents the abstraction between the socket and the rest of the MUD.
 * It is used to keep the details of the connection away from the developer, and to allow
 * arbitrary details to be attached to the connection.
 */

@implementation KMConnectionCoordinator

static NSString* sendMessageBase(NSString* message) {
	if(![[message substringFromIndex:([message length] - 2)] isEqualToString:@"\n\r"])
		message = [message stringByAppendingFormat:@"\n\r"];
	NSString* (^sendMessageHelper)(NSString*) = ^(NSString* input){
		for(id<KMWriteHook> hook in [[[KMServer getDefaultServer] getConnectionPool] hooks]) {
			input = [hook processHook:input];
		}
		return input;
	};
	NSString* current = [message copy];
	message = sendMessageHelper(message);
	while (![message isEqualToString:current]) {
		current = [message copy];
		message = sendMessageHelper(message);
	}
	return message;
}

-(BOOL) sendMessage:(NSString*)message
{
	message = sendMessageBase(message);
	NSData* data = [message dataUsingEncoding:NSASCIIStringEncoding];
	if(CFSocketSendData(socket, NULL, (CFDataRef)data, 0) != kCFSocketSuccess) {
		NSLog(@"Error sending data to connection, closing connection...");
		[[[KMServer getDefaultServer] getConnectionPool] removeConnection:self];
		return NO;
	}
	return YES;
}

-(void) sendMessageToBuffer:(NSString *)message
{
	message = sendMessageBase(message);
	if(!outputBuffer)
		outputBuffer = [[NSString alloc] init];
	outputBuffer = [outputBuffer stringByAppendingString:message];
}

-(CFSocketRef) getSocket
{
	return socket;
}

-(void) setSocket:(CFSocketRef)newSocket
{
	socket = newSocket;
}

-(NSString*) getInputBuffer
{
	return inputBuffer;
}

-(void) setInputBuffer:(NSString*)buffer
{
	inputBuffer = [buffer copy];
}

-(void) setLastReadTime:(NSDate*)time
{
	lastReadTime = [time copy];
}

-(NSDate*) getLastReadTime
{
	return lastReadTime;
}

@synthesize outputBuffer;
@end
