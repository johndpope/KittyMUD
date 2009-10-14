//
//  KMCommandInterpreter.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/6/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMInterpreter.h"
#import "KMCommandInterpreterLogic.h"
#import "KMConnectionCoordinator.h"

struct KMCommandDefinition {
	SEL method;
	NSString* name;
	NSArray* optArgs;
	NSArray* aliases;
	NSArray* flags;
	NSDictionary* help;
	int minLevel;
	id target;
	KMConnectionCoordinator* coordinator;
};

typedef __strong struct KMCommandDefinition* KMCommandDefinitionRef;

@interface KMBox : NSObject {
	void* item;
}

-(id) initWithObject:(void*)object;

+(id) box:(void*)object;

-(void*) unbox;

@end

@interface KMCommandInterpreter : NSObject <KMInterpreter> {
	NSMutableArray* commands;
	NSMutableDictionary* logics;
	id<KMCommandInterpreterLogic> defaultTarget;
}

-(id) init;

-(void) registerLogic:(Class)clogic;

-(void) registerLogic:(Class)clogic asDefaultTarget:(BOOL)dt;

-(void)registerCommand:(id)target selector:(SEL)commandSelector withName:(NSString*)name andOptionalArguments:(NSArray*)optional andAliases:(NSArray*)aliases andFlags:(NSArray*)flags withMinimumLevel:(int)level;

-(void) interpret:(id)coordinator;

-(void) registerCommandHelp:(NSString*)name usingShortText:(NSString*)shorttext withLongTextFile:(NSString*)longtextname;

CHEDC(help);
CDECL(help) command:(NSString*)command;

@property (readonly) NSArray* commands;

@property (retain) id<KMCommandInterpreterLogic> defaultTarget;

@property (retain) KMConnectionCoordinator* coordinator;

@end

@interface KMCommandInterpreter ()

-(BOOL) validateInput:(KMCommandDefinitionRef)command forCoordinator:(id)coordinator onlyFlagsAndLevel:(BOOL)ofl;

-(KMCommandDefinitionRef) findCommandByName:(NSString*)name;

@end