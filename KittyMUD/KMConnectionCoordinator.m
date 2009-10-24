//
//  KMConnectionCoordinator.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/12/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMConnectionCoordinator.h"
#import "KMServer.h"
#import "KMCharacter.h"


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
	
	return (1ULL << (flagpower % 64)) == ([[flagbase objectAtIndex:(flagpower / 64)] unsignedLongLongValue] & (1ULL << (flagpower % 64)));
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
	[flagbase replaceObjectAtIndex:(flagpower / 64) withObject:[NSNumber numberWithUnsignedLongLong:[[flagbase objectAtIndex:(flagpower / 64)] unsignedLongLongValue] | (1ULL << (flagpower % 64))]];
}

-(void) clearFlag:(NSString*)flagName
{
	NSString* fp = [flags objectForKey:flagName];
	int flagpower = -1;
	if( fp == nil )
		return;
	flagpower = [fp intValue];
	if([self isFlagSet:flagName])
		[flagbase replaceObjectAtIndex:(flagpower / 64) withObject:[NSNumber numberWithUnsignedLongLong:[[flagbase objectAtIndex:(flagpower / 64)] unsignedLongLongValue] ^ (1ULL << (flagpower % 64))]];
}

-(void) debugPrintFlagStatus
{
	for(NSString* flag in [flags allKeys])
	{
		NSString* flagstatus;
		if([self isFlagSet:flag])
			flagstatus = @"SET";
		else
			flagstatus = @"CLEAR";
		NSLog(@"Flag %@: %@", flag, flagstatus);
	}
}

static NSString* sendMessageBase(NSString* message) {
	message = [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSString* (^sendMessageHelperStrip)(NSString*) = ^(NSString* input){
		for(id<KMWriteHook> hook in [[[KMServer getDefaultServer] getConnectionPool] hooks]) {
			input = [hook processHook:input replace:NO];
		}
		return input;
	};
	NSString* msg = [message copy];
	msg = sendMessageHelperStrip(msg);
	BOOL isEntry = [msg characterAtIndex:([msg length] - 1)] == ':';
	BOOL isMenu = [msg characterAtIndex:([msg length] - 1)] == '>';
	if([msg length] > 2 && ![[msg substringFromIndex:([msg length] - 2)] isEqualToString:@"\n\r"] && !isEntry && !isMenu)
		message = [message stringByAppendingString:@"\n\r"];
	else if (isEntry && !isMenu)
		message = [message stringByAppendingString:@" "];
	else if (isMenu)
		message = [[message substringToIndex:([message length] - 1)] stringByAppendingString:@"\n\r\n\r"];
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
	NSData* data = [message dataUsingEncoding:NSUTF8StringEncoding];
	if(CFSocketSendData(socket, NULL, (CFDataRef)data, 0) != kCFSocketSuccess) {
		NSLog(@"Error sending data to connection, closing connection...");
		[[[KMServer getDefaultServer] getConnectionPool] removeConnection:self];
		return NO;
	}
	return YES;
}

-(void) sendMessageToBuffer:(NSString *)message
{
	if([self isFlagSet:@"message-direct"]) {
		[self sendMessage:message];
		return;
	}
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

-(void) setInterpreter:(id<KMInterpreter>)interp {
	interpreter = interp;
}

-(void) saveToXML:(NSString*)dirToSave
{
	if(![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.xml",dirToSave,[self valueForKeyPath:@"properties.name"]]])
		[[NSFileManager defaultManager] createFileAtPath:[NSString stringWithFormat:@"%@/%@.xml",dirToSave,[self valueForKeyPath:@"properties.name"]] contents:nil attributes:nil];
	NSFileHandle* fh = [NSFileHandle fileHandleForWritingAtPath:[NSString stringWithFormat:@"%@/%@.xml",dirToSave,[self valueForKeyPath:@"properties.name"]]];
	NSXMLElement* rootElement = [[NSXMLElement alloc] initWithName:@"account"];
	NSXMLNode* nameAttribute = [NSXMLNode attributeWithName:@"name" stringValue:[self valueForKeyPath:@"properties.name"]];
	NSXMLNode* passwordAttribute = [NSXMLNode attributeWithName:@"password" stringValue:[self valueForKeyPath:@"properties.password"]];
	[rootElement addAttribute:nameAttribute];
	[rootElement addAttribute:passwordAttribute];
	NSXMLElement* flagsElement = [[NSXMLElement alloc] initWithName:@"flags"];
	for(NSString* flag in [flags allKeys]) {
		if([self isFlagSet:flag]) {
			NSXMLElement* flagElement = [[NSXMLElement alloc] initWithName:@"flag"];
			NSXMLNode* flagNameAttribute = [NSXMLNode attributeWithName:@"flagname" stringValue:flag];
			NSXMLNode* isSetAttribute = [NSXMLNode attributeWithName:@"isset" stringValue:@"true"];
			[flagElement addAttribute:flagNameAttribute];
			[flagElement addAttribute:isSetAttribute];
			[flagsElement addChild:flagElement];
		}
	}
	[rootElement addChild:flagsElement];
	for(KMCharacter* character in [self getCharacters]) {
		[rootElement addChild:[character saveToXML]];
	}
	NSXMLDocument* xdoc = [[NSXMLDocument alloc] initWithRootElement:rootElement];
	[fh writeData:[xdoc XMLDataWithOptions:NSXMLNodePrettyPrint]];
	[fh closeFile];
}

-(void) loadFromXML:(NSString*)dirToSave
{
	NSFileHandle* fh = [NSFileHandle fileHandleForReadingAtPath:[NSString stringWithFormat:@"%@/%@.xml",dirToSave,[self valueForKeyPath:@"properties.name"]]];
	NSXMLDocument* xdoc = [[NSXMLDocument alloc] initWithData:[fh readDataToEndOfFile] options:0 error:NULL];
	NSXMLElement* rootElement = [xdoc rootElement];
	[self setValue:[[rootElement attributeForName:@"password"] stringValue] forKeyPath:@"properties.password"];
	NSArray* flagElems = [rootElement elementsForName:@"flags"];
	if([flagElems count] > 0) {
		NSXMLElement* flagsElement = [flagElems objectAtIndex:0];
		NSArray* flagElements = [flagsElement elementsForName:@"flag"];
		for(NSXMLElement* flagElement in flagElements) {
			NSXMLNode* flagNameAttribute = [flagElement attributeForName:@"flagname"];
			NSXMLNode* isSetAttribute = [flagElement attributeForName:@"isset"];
			if([[isSetAttribute stringValue] isEqualToString:@"true"])
				[self setFlag:[flagNameAttribute stringValue]];
		}
	}
	NSArray* characterElements = [rootElement elementsForName:@"character"];
	for(NSXMLElement* characterElement in characterElements) {
		[[self getCharacters] addObject:[KMCharacter loadFromXML:characterElement]];
	}
	[fh closeFile];
}

-(id) valueForUndefinedKey:(NSString *)key {
	return [NSNull null];
}

-(void) setValue:(id)value forUndefinedKey:(NSString*)key {
	return;
}

@synthesize lastReadTime;
@synthesize outputBuffer;
@synthesize currentState;
@synthesize interpreter;
@synthesize characters;
@synthesize flagbase;
@synthesize flags;
@synthesize currentbitpower;
@synthesize properties;
@synthesize inputBuffer;
@end
