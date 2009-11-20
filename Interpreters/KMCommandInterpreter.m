//
//  KMCommandInterpreter.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/6/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMCommandInterpreter.h"
#import "KMConnectionCoordinator.h"
#import "KMCharacter.h"
#import "KMState.h"
#import "KMServer.h"
#import <objc/runtime.h>

@implementation KMCommandInterpreter

-(id) init {
	self = [super init];
	if(self) {
		commands = [[NSMutableArray alloc] init];
		logics = [[NSMutableDictionary alloc] init];
		[self commandSetuphelp:self];
		[self commandHelphelp:self];
		[self commandSetuprebuildlogics:self];
		[self commandHelprebuildlogics:self];
		[self commandSetupdisplaycommand:self];
		defaultTarget = nil;
		myLogics = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void) registerLogic:(Class)clogic {
	[self registerLogic:clogic asDefaultTarget:NO];
}

-(void) registerLogic:(Class)clogic asDefaultTarget:(BOOL)dt
{
	if(!class_conformsToProtocol(clogic, @protocol(KMCommandInterpreterLogic)))
		return;
	id<KMCommandInterpreterLogic> logic = [[clogic alloc] initializeWithCommandInterpreter:self];
	unsigned int count;
	Method* classMethods = class_copyMethodList(clogic, &count);
	if(count == 0)
		return;
	NSMutableDictionary* classMethodD = [[NSMutableDictionary alloc] init];
	for(int i = 0; i < count; i++) {
		NSString* methodName = [[NSString alloc] initWithCString:sel_getName(method_getName(classMethods[i]))];
		[classMethodD setObject:[NSValue valueWithPointer:&(classMethods[i])] forKey:methodName];
	}
	NSPredicate* filterPred = [NSPredicate predicateWithFormat:@"self beginswith 'commandSetup'"];
	NSArray* classMethodA = [classMethodD allKeys];
	NSArray* classMethodB = [classMethodA filteredArrayUsingPredicate:filterPred];
	NSMethodSignature* sig = [KMCommandInterpreter instanceMethodSignatureForSelector:@selector(commandSetuphelp:)];
	NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
	for(NSString* method in classMethodB) {
		Method* met = [[classMethodD objectForKey:method] pointerValue];
		[invocation setTarget:logic];
		[invocation setSelector:method_getName(*met)];
		[invocation setArgument:&self atIndex:2];
		[invocation invoke];
	}
	NSPredicate* helpPred = [NSPredicate predicateWithFormat:@"self beginswith 'commandHelp'"];
	NSArray* helpMethod = [classMethodA filteredArrayUsingPredicate:helpPred];
	for(NSString* method in helpMethod) {
		[invocation setTarget:logic];
		Method* met = [[classMethodD objectForKey:method] pointerValue];
		[invocation setSelector:method_getName(*met)];
		[invocation setArgument:&self atIndex:2];
		[invocation invoke];
	}
	if(dt)
		[self setDefaultTarget:logic];
	[myLogics addObject:NSStringFromClass(clogic)];
}	

-(void) registerCommandHelp:(NSString*)name usingShortText:(NSString*)shorttext withLongTextFile:(NSString*)longtextname {
	KMCommandInfo* command = [self findCommandByName:name];
	if(!command)
		return;
	[command setHelp:[[NSMutableDictionary alloc] initWithObjectsAndKeys:shorttext,@"short",longtextname,@"long"]];
}

-(void)registerCommand:(id)target selector:(SEL)commandSelector withName:(NSString*)name andOptionalArguments:(NSArray*)optional andAliases:(NSArray*)aliases andFlags:(NSArray*)cflags withMinimumLevel:(int)level
{
	KMCommandInfo* cmd = [self findCommandByName:name];
	if(cmd != nil) {
		[commands removeObject:cmd];
	}
	KMCommandInfo* command = [[KMCommandInfo alloc] init];
	[command setName:name];
	[command setAliases:[[NSMutableArray alloc] initWithArray:aliases]];
	[command setOptArgs:[[NSMutableArray alloc] initWithArray:optional]];
	[command setMethod:NSStringFromSelector(commandSelector)];
	[command setCmdflags:[[NSMutableArray alloc] initWithArray:cflags]];
	[command setMinLevel:level];
	[command setTarget:target];
	[commands addObject:command];
	[logics setObject:target forKey:name];
}

-(void) interpret:(id)coordinator
{
	NSArray* commandmakeup = [[coordinator getInputBuffer] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSString* commandName = [commandmakeup objectAtIndex:0];
	KMCommandInfo* command = [self findCommandByName:commandName];
	
	if(command == NULL)
	{
		[coordinator sendMessageToBuffer:@"Unknown command entered."];
		return;
	}
	
	if([commandmakeup count] > 1 && [[commandmakeup objectAtIndex:1] isEqualToString:@"-help"] && [self validateInput:command forCoordinator:coordinator onlyFlagsAndLevel:YES]) {
		if(![[command help] objectForKey:@"short"]) {
			[coordinator sendMessageToBuffer:@"Help not available for command."];
			if(defaultTarget) {
				if([defaultTarget isRepeating])
					[defaultTarget repeatCommandsToCoordinator:coordinator];
			}
			return;
		}
		[coordinator sendMessageToBuffer:[[command help] objectForKey:@"short"]];
		return;
	}
	if(![self validateInput:command forCoordinator:coordinator onlyFlagsAndLevel:NO])
	{
		[coordinator sendMessageToBuffer:@"Unknown command entered."];
		return;
	}
	NSMethodSignature* sig = [[[command target] class] instanceMethodSignatureForSelector:NSSelectorFromString([command method])];
	NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
	[invocation setTarget:[command target]];
	[invocation setSelector:NSSelectorFromString([command method])];
	[invocation setArgument:&coordinator atIndex:2];
	for(int i = 1; i < [commandmakeup count]; i++) {
		__strong char* argType = method_copyArgumentType(class_getInstanceMethod([[command target] class], NSSelectorFromString([command method])), i + 2);
		if(!strcmp(argType,"i")) {
			__strong int num = [[commandmakeup objectAtIndex:i] intValue];
			[invocation setArgument:&num atIndex:(i+2)];
		} else {
			id arg = [commandmakeup objectAtIndex:i];
			[invocation setArgument:&arg atIndex:(i+2)];
		}
	}
	[invocation invoke];
	if(![coordinator isFlagSet:@"no-message"]) {
		[[coordinator currentState] softRebootMessage:coordinator];
		[coordinator setFlag:@"no-message"];
	}
}

-(BOOL) validateInput:(KMCommandInfo*)command forCoordinator:(id)coordinator onlyFlagsAndLevel:(BOOL)ofl
{
	Method m = class_getInstanceMethod([[command target] class], NSSelectorFromString([command method]));
	int numArgs = method_getNumberOfArguments(m);
	NSArray* commandmakeup = [[coordinator getInputBuffer] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if(!ofl) {
		int numOpt = [[command optArgs] count];
		if([commandmakeup count] < (numArgs - 3 - numOpt)) {
			[coordinator sendMessage:[NSString stringWithFormat:@"%d arguments expected, %d gotten", numArgs, [commandmakeup count]]];
			return NO;
		}
	}
	if([command cmdflags]) {
		for(NSString* flag in [command cmdflags]) {
			if(![[coordinator valueForKeyPath:@"properties.current-character"] isFlagSet:flag]) {
				return NO;
			}
		}
	}
	KMCharacter* character = [[coordinator getProperties] objectForKey:@"current-character"];
	if([[[character stats] findStatWithPath:@"level"] statvalue] < [command minLevel])
		return NO;
	return YES;
}

-(KMCommandInfo*) findCommandByName:(NSString*)name
{
	for(KMCommandInfo* cmd in commands) {
		if([[cmd name] hasPrefix:name])
			return cmd;
		NSArray* aliases = [cmd aliases];
		NSPredicate* alias = [NSPredicate predicateWithFormat:@"self beginswith[cd] %@", name];
		
		NSArray* aliasesA = [aliases filteredArrayUsingPredicate:alias];
		if([aliasesA count] > 0)
			return cmd;
	}
	return nil;
}

CHELP(help,@"Displays long help for the given command.",nil)
CIMPL(help,help:command:,@"command",nil,nil,1) command:(NSString*)command {
	if(command == nil) {
		if(defaultTarget != nil)
			[defaultTarget displayHelpToCoordinator:coordinator];
		return;
	}
	KMCommandInfo* cmd = [self findCommandByName:command];
	if(!cmd || ![self validateInput:cmd forCoordinator:coordinator onlyFlagsAndLevel:YES]) {
		[coordinator sendMessageToBuffer:@"Unknown command."];
		return;
	}
	if(![[cmd help] objectForKey:@"long"]) {
		[coordinator sendMessageToBuffer:@"Help unavailable for command."];
		return;
	}
}

CHELP(rebuildlogics,@"Rebuilds the logics for all command interpreters in use at the time.  Used when soft rebooting with changed commands.",nil)
CIMPL(rebuildlogics,rebuildlogics:,nil,nil,@"admin",1) {
	for(KMConnectionCoordinator* coord in [[[KMServer getDefaultServer] getConnectionPool] connections]) {
		if([[coord interpreter] isKindOfClass:[KMCommandInterpreter class]]) {
			[(KMCommandInterpreter*)[coord interpreter] rebuildLogics:coord];
		}
	}
}

CIMPL(displaycommand,displaycommand:command:,nil,nil,nil,1) command:(NSString*)command {
	KMCommandInfo* cmd = [self findCommandByName:command];
	if(cmd == nil) {
		[coordinator sendMessageToBuffer:@"No command found."];
	}
	[coordinator sendMessageToBuffer:[NSString stringWithFormat:@"Command %@, Optional Arguments: %d, Flags Required: %d",[cmd name], [[cmd optArgs] count], [[cmd cmdflags] count]]];
}

-(void) rebuildLogics:(id)coordinator {
	[coordinator sendMessageToBuffer:@"Rebuilding your command interpreter logics...please stand by."];
	[commands removeAllObjects];
	[self commandSetuphelp:self];
	[self commandHelphelp:self];
	[self commandSetuprebuildlogics:self];
	[self commandHelprebuildlogics:self];
	[self commandSetupdisplaycommand:self];
	for(NSString* logic in myLogics) {
		Class clogic = NSClassFromString(logic);
		[self registerLogic:clogic];
	}
	[coordinator sendMessageToBuffer:@"Rebuilding logic complete."];
}

@synthesize commands;
@synthesize coordinator;
@synthesize defaultTarget;
@synthesize logics;
@synthesize myLogics;
@end
