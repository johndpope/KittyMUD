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

-(id) init
{
	self = [super init];
	if( self ) {
		flags = [[NSMutableDictionary alloc] init];
		flagbase = [[NSMutableArray alloc] init];
		[flagbase addObject:[NSNumber numberWithUnsignedLongLong:0]];
		properties = [[NSMutableDictionary alloc] init];
		currentbitpower = 0; // this will be saved in the save file so we make sure we dont overwrite existing flags
		characters = [[NSMutableArray alloc] init];
	}
	return self;
}

-(BOOL) isFlagSet:(NSString*)flagName
{
	NSString* fp = [flags objectForKey:flagName];
	int flagpower = -1;
	if(fp == nil)
		return NO;
	flagpower = [fp intValue];
	
	return (1 << (flagpower % 64)) == ([[flagbase objectAtIndex:(flagpower / 64)] unsignedLongLongValue] & (1 << (flagpower % 64)));
}

-(void) setFlag:(NSString*)flagName
{
	NSString* fp = [flags objectForKey:flagName];
	int flagpower = -1;
	if( fp != nil )
		flagpower = [fp intValue];
	else {
		[flags setObject:[NSString stringWithFormat:@"%d", currentbitpower] forKey:flagName];
		if([flagbase count] <= ((currentbitpower) / 64))
			[flagbase addObject:[NSNumber numberWithUnsignedLongLong:0]];
		flagpower = currentbitpower++;
	}
	[flagbase replaceObjectAtIndex:(flagpower / 64) withObject:[NSNumber numberWithUnsignedLongLong:[[flagbase objectAtIndex:(flagpower / 64)] unsignedLongLongValue] | (1 << (flagpower % 64))]];
}

-(void) clearFlag:(NSString*)flagName
{
	NSString* fp = [flags objectForKey:flagName];
	int flagpower = -1;
	if( fp == nil )
		return;
	flagpower = [fp intValue];
	if([self isFlagSet:flagName])
		[flagbase replaceObjectAtIndex:(flagpower / 64) withObject:[NSNumber numberWithUnsignedLongLong:[[flagbase objectAtIndex:(flagpower / 64)] unsignedLongLongValue] ^ (1 << (flagpower % 64))]];
}

-(void) debugPrintFlagStatus
{
	for(NSString* flag in [flags allKeys])
	{
		NSString* flagstatus;
		if([self isFlagSet:flag])
			continue;
		else
			flagstatus = @"CLEAR";
		NSLog(@"Flag %@: %@", flag, flagstatus);
	}
}

static NSString* sendMessageBase(NSString* message) {
	BOOL isEntry = [[message substringFromIndex:([message length] - 1)] isEqualToString:@":"];
	if(![[message substringFromIndex:([message length] - 2)] isEqualToString:@"\n\r"] && !isEntry)
		message = [message stringByAppendingString:@"\n\r"];
	else if (isEntry)
		message = [message stringByAppendingString:@" "];
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


-(NSMutableDictionary*) getProperties
{
	return properties;
}

-(void) setProperties:(NSMutableDictionary *)value
{
	return; // no-op properties is read-only
}

@synthesize outputBuffer;
@synthesize currentState;
@synthesize interpreter;
@synthesize characters;
@end
