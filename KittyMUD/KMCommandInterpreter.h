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
#import "KMCommandInfo.h"

@interface KMBox : NSObject {
	void* item;
}

-(id) initWithObject:(void*)object;

+(id) box:(void*)object;

-(void*) unbox;

-(id) valueForUndefinedKey:(NSString *)key;

-(void) setValue:(id)value forUndefinedKey:(NSString*)key;

@property (getter=unbox) void* item;
@end

@interface KMCommandInterpreter : NSObject <KMInterpreter> {
	NSMutableArray* commands;
	NSMutableDictionary* logics;
	id<KMCommandInterpreterLogic> defaultTarget;
	NSMutableArray* myLogics;
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

@property (retain) NSMutableDictionary* logics;
@end

@interface KMCommandInterpreter ()

-(BOOL) validateInput:(KMCommandInfo*)command forCoordinator:(id)coordinator onlyFlagsAndLevel:(BOOL)ofl;

-(KMCommandInfo*) findCommandByName:(NSString*)name;

-(void) rebuildLogics;

@end