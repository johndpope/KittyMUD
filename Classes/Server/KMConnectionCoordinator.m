//
//  KMConnectionCoordinator.m
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

#import "KMConnectionCoordinator.h"
#import "KMServer.h"
#import "KMCharacter.h"
#import "KMBasicInterpreter.h"
#import <ECScript/ECSObjcExtensions.h>
#import <ECScript/ECSSymbol.h>
#import <ECScript/ECSSymbolTable.h>
#import <ECScript/NSMutableDictionary+ECSExtensions.h>

/*
 * This class represents the abstraction between the socket and the rest of the MUD.
 * It is used to keep the details of the connection away from the developer, and to allow
 * arbitrary details to be attached to the connection.
 */

@implementation KMConnectionCoordinator

+(KMConnectionCoordinator*) getCoordinatorForCharacterWithName:(NSString *)name {
	for(KMConnectionCoordinator* coordinator in [[[KMServer getDefaultServer] getConnectionPool] connections]) {
		if(![[coordinator valueForKeyPath:@"properties.current-character.properties.name"] caseInsensitiveCompare:name])
			return coordinator;
	}
	return nil;
}

-(id) copyWithZone:(NSZone*) __unused zone {
	return self;
}

-(id) init
{
	self = [super init];
	if( self ) {
		characters = [[NSMutableArray alloc] init];
        outputHooks = [NSMutableDictionary dictionary];
		[self setValue:[[KMBasicInterpreter alloc] init] forKeyPath:@"properties.current-interpreter"];
	}
	return self;
}

static NSString* sendMessageBase(KMConnectionCoordinator* _self, NSString* message) {
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
    NSMutableDictionary* context = [NSMutableDictionary dictionary];
    [context createSymbolTable];
    ECSSymbol* csym = [[context symbolTable] symbolWithName:@"coordinator"];
    csym.value = _self;
    message = [message evaluateWithContext:context];
	return message;
}

-(BOOL) sendMessage:(NSString*)message,...
{
	va_list args;
	va_start(args,message);
	message = [[NSString alloc] initWithFormat:message arguments:args];
	va_end(args);
	message = sendMessageBase(self,message);
	NSData* data = [message dataUsingEncoding:NSUTF8StringEncoding];
	if(CFSocketSendData(socket, NULL, (CFDataRef)data, 0) != kCFSocketSuccess) {
		OCLog(@"kittymud",info,@"Error sending data to connection, closing connection...");
		[[[KMServer getDefaultServer] getConnectionPool] removeConnection:self];
		return NO;
	}
	return YES;
}

-(void) sendMessageToBuffer:(NSString *)message,...
{
	va_list args;
	va_start(args,message);
	message = [[NSString alloc] initWithFormat:message arguments:args];
	va_end(args);
	if([self isFlagSet:@"message-direct"]) {
		[self sendMessage:message];
		return;
	}
	message = sendMessageBase(self,message);
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

-(void) releaseSocket {
	CFRelease(socket);
}

-(BOOL) createSocketWithHandle:(CFSocketNativeHandle)handle andCallback:(CFSocketCallBack)callback;
{
	CFSocketContext newContext = { 0, self, NULL, NULL, NULL };
	socket = CFSocketCreateWithNative(kCFAllocatorDefault, handle, kCFSocketDataCallBack, callback, &newContext);
	if(socket == NULL) {
		OCLog(@"kittymud",info,@"[WARNING] Error creating new socket, not adding to pool and closing...");
		close( handle );
		return NO;
	}
	CFRunLoopSourceRef connRLS = CFSocketCreateRunLoopSource(kCFAllocatorDefault, socket, 0);
	CFRunLoopRef rl = CFRunLoopGetCurrent();
	CFRunLoopAddSource(rl, connRLS, kCFRunLoopCommonModes);
	CFRelease(connRLS);
	return YES;
}

-(void) saveToXML:(NSString*)dirToSave
{
    return [self saveToXML:dirToSave withState:NO];
}

-(void) saveToXML:(NSString*)dirToSave withState:(BOOL)withState
{
	if(![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.xml",dirToSave,[self valueForKeyPath:@"properties.name"]]])
		[[NSFileManager defaultManager] createFileAtPath:[NSString stringWithFormat:@"%@/%@.xml",dirToSave,[self valueForKeyPath:@"properties.name"]] contents:nil attributes:nil];
	NSFileHandle* fh = [NSFileHandle fileHandleForWritingAtPath:[NSString stringWithFormat:@"%@/%@.xml",dirToSave,[self valueForKeyPath:@"properties.name"]]];
	NSXMLElement* rootElement = [[NSXMLElement alloc] initWithName:@"account"];
	NSXMLNode* nameAttribute = [NSXMLNode attributeWithName:@"name" stringValue:[self valueForKeyPath:@"properties.name"]];
	NSXMLNode* passwordAttribute = [NSXMLNode attributeWithName:@"password" stringValue:[self valueForKeyPath:@"properties.password"]];
	[rootElement addAttribute:nameAttribute];
	[rootElement addAttribute:passwordAttribute];
    if(withState) {
        NSXMLNode* stateAttribute = [NSXMLNode attributeWithName:@"state" stringValue:NSStringFromClass([[self valueForKeyPath:@"properties.current-state"] class])];
        [rootElement addAttribute:stateAttribute];
        NSXMLNode* currentCharacter = [NSXMLNode attributeWithName:@"character" stringValue:[self valueForKeyPath:@"properties.current-character.properties.name"]];
        [rootElement addAttribute:currentCharacter];
    }
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
    [self loadFromXML:dirToSave withState:NO];
}

-(void) loadFromXML:(NSString*)dirToSave withState:(BOOL)withState
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
    if(withState) {
        [self setValue:[[NSClassFromString([[rootElement attributeForName:@"state"] stringValue]) alloc] initWithCoordinator:self] forKeyPath:@"properties.current-state"];
        KMGetInterpreterForState([self valueForKeyPath:@"properties.current-state"],interp);
        [self setValue:interp forKeyPath:@"properties.current-interpreter"];
        NSString* characterName = [[rootElement attributeForName:@"character"] stringValue];
        NSPredicate* pred = [NSPredicate predicateWithFormat:@"self.properties.name like[cd] %@",characterName];
        NSArray* _characters = [[self getCharacters] filteredArrayUsingPredicate:pred];
        // this should not ever crash, but we'll add a check here just in case
        if(_characters.count) {
            [self setValue:[_characters objectAtIndex:0] forKeyPath:@"properties.current-character"];
        }
    }
	[fh closeFile];
}

-(void) addOutputHook:(NSString*)key block:(KMOutputHook)hook {
    [self.outputHooks setObject:hook forKey:key];
}

-(id) valueForUndefinedKey:(NSString*) key {
    if([key isEqualToString:@"character"])
        return [self valueForKeyPath:@"properties.current-character"];
    return nil;
}

@synthesize lastReadTime;
@synthesize outputBuffer;
@synthesize characters;
@synthesize inputBuffer;
@synthesize outputHooks;
@end
