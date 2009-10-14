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
#import "KMMessageState.h"
#import <objc/runtime.h>

@implementation KMBox

-(id) initWithObject:(void*)object {
	self = [super init];
	if(self) {
		item = object;
	}
	return self;
}

+(id) box:(void*)object {
	return [[KMBox alloc] initWithObject:object];
}

-(void*) unbox {
	return item;
}

@end

@implementation KMCommandInterpreter

-(id) init {
	self = [super init];
	if(self) {
		commands = [[NSMutableArray alloc] init];
		[self commandSetuphelp:self];
		[self commandHelphelp:self];
		defaultTarget = nil;
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
		[classMethodD setObject:[KMBox box:&(classMethods[i])] forKey:methodName];
	}
	NSPredicate* filterPred = [NSPredicate predicateWithFormat:@"self beginswith 'commandSetup'"];
	NSArray* classMethodA = [classMethodD allKeys];
	NSArray* classMethodB = [classMethodA filteredArrayUsingPredicate:filterPred];
	NSMethodSignature* sig = [KMCommandInterpreter instanceMethodSignatureForSelector:@selector(commandSetuphelp:)];
	NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
	for(NSString* method in classMethodB) {
		Method* met = [[classMethodD objectForKey:method] unbox];
		[invocation setTarget:logic];
		[invocation setSelector:method_getName(*met)];
		[invocation setArgument:&self atIndex:2];
		[invocation invoke];
	}
	NSPredicate* helpPred = [NSPredicate predicateWithFormat:@"self beginswith 'commandHelp'"];
	NSArray* helpMethod = [classMethodA filteredArrayUsingPredicate:helpPred];
	for(NSString* method in helpMethod) {
		[invocation setTarget:logic];
		Method* met = [[classMethodD objectForKey:method] unbox];
		[invocation setSelector:method_getName(*met)];
		[invocation setArgument:&self atIndex:2];
		[invocation invoke];
	}
	if(dt)
		[self setDefaultTarget:logic];
}	

-(void) registerCommandHelp:(NSString*)name usingShortText:(NSString*)shorttext withLongTextFile:(NSString*)longtextname {
	KMCommandDefinitionRef command = [self findCommandByName:name];
	if(!command)
		return;
	command->help = [[NSDictionary alloc] initWithObjectsAndKeys:shorttext,@"short",longtextname,@"long"];
}

-(void)registerCommand:(id)target selector:(SEL)commandSelector withName:(NSString*)name andOptionalArguments:(NSArray*)optional andAliases:(NSArray*)aliases andFlags:(NSArray*)flags withMinimumLevel:(int)level
{
	KMCommandDefinitionRef command = (KMCommandDefinitionRef)malloc(sizeof(struct KMCommandDefinition));
	command->name = name;
	command->aliases = [aliases copy];
	command->optArgs = [optional copy];
	command->method = commandSelector;
	command->flags = [flags copy];
	command->minLevel = level;
	command->target = target;
	[commands addObject:[KMBox box:command]];
	[logics setObject:target forKey:name];
}

-(void) interpret:(id)coordinator
{
	NSArray* commandmakeup = [[coordinator getInputBuffer] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSString* commandName = [commandmakeup objectAtIndex:0];
	KMCommandDefinitionRef command = [self findCommandByName:commandName];
	
	if(command == NULL)
	{
		[coordinator sendMessageToBuffer:@"Unknown command entered."];
		return;
	}
	
	if([commandmakeup count] > 1 && [[commandmakeup objectAtIndex:1] isEqualToString:@"-help"] && [self validateInput:command forCoordinator:coordinator onlyFlagsAndLevel:YES]) {
		if(![(command->help) objectForKey:@"short"]) {
			[coordinator sendMessageToBuffer:@"Help not available for command."];
			if(defaultTarget) {
				if([defaultTarget isRepeating])
					[defaultTarget repeatCommandsToCoordinator:coordinator];
			}
			return;
		}
		[coordinator sendMessageToBuffer:[(command->help) objectForKey:@"short"]];
		return;
	}
	if(![self validateInput:command forCoordinator:coordinator onlyFlagsAndLevel:NO])
	{
		[coordinator sendMessageToBuffer:@"Unknown command entered."];
		return;
	}
	NSMethodSignature* sig = [[(command->target) class] instanceMethodSignatureForSelector:(command->method)];
	NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
	[invocation setTarget:(command->target)];
	[invocation setSelector:(command->method)];
	[invocation setArgument:&coordinator atIndex:2];
	for(int i = 1; i < [commandmakeup count]; i++) {
		__strong char* argType = method_copyArgumentType(class_getInstanceMethod([(command->target) class], (command->method)), i + 2);
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
		if([[coordinator currentState] conformsToProtocol:@protocol(KMMessageState)]) {
			[(id<KMMessageState>)[coordinator currentState] sendMessageToCoordinator:coordinator];
		}
	}
	else
		[coordinator clearFlag:@"no-message"];
}

-(BOOL) validateInput:(KMCommandDefinitionRef)command forCoordinator:(id)coordinator onlyFlagsAndLevel:(BOOL)ofl
{
	Method m = class_getInstanceMethod([(command->target) class], (command->method));
	int numArgs = method_getNumberOfArguments(m);
	NSArray* commandmakeup = [[coordinator getInputBuffer] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if(!ofl) {
		int numOpt = [(command->optArgs) count];
		if([commandmakeup count] <= (numArgs - 3 - numOpt)) // account for the implicit coordinator argument, and the hidden self and _cmd arguments and optional arguments
			return NO;
		for(int idx = 3; idx < numArgs; idx++) {
			__strong char* argType = method_copyArgumentType(m, idx);
			if(!strcmp(argType,"i"))
			{
				int i = [[commandmakeup objectAtIndex:(idx - 2)] intValue];
				if(i == 0 && ![[commandmakeup objectAtIndex:(idx - 2)] isEqualToString:@"0"])
					return NO;
			}
		}
	}
	if(command->flags) {
		for(NSString* flag in command->flags) {
			if(![[coordinator valueForKeyPath:@"properties.current-character"] isFlagSet:flag])
				return NO;
		}
	}
	KMCharacter* character = [[coordinator getProperties] objectForKey:@"current-character"];
	if([[[character stats] findStatWithPath:@"level"] statvalue] < command->minLevel)
		return NO;
	return YES;
}

-(KMCommandDefinitionRef) findCommandByName:(NSString*)name
{
	for(KMBox* box in commands) {
		KMCommandDefinitionRef cmd = (KMCommandDefinitionRef)[box unbox];
		if([(cmd->name) hasPrefix:name])
			return cmd;
		NSArray* aliases = cmd->aliases;
		NSPredicate* alias = [NSPredicate predicateWithFormat:@"self beginswith[cd] %@", name];
		NSArray* aliasesA = [aliases filteredArrayUsingPredicate:alias];
		if([aliasesA count] > 0)
			return cmd;
	}
	return NULL;
}

CHELP(help,@"Displays long help for the given command.",nil)
CIMPL(help,help:command:,@"command",nil,nil,1) command:(NSString*)command {
	if(command == nil) {
		if(defaultTarget != nil)
			[defaultTarget displayHelpToCoordinator:coordinator];
		return;
	}
	KMCommandDefinitionRef cmd = [self findCommandByName:command];
	if(!cmd || ![self validateInput:cmd forCoordinator:coordinator onlyFlagsAndLevel:YES]) {
		[coordinator sendMessageToBuffer:@"Unknown command."];
		return;
	}
	if(![cmd->help objectForKey:@"long"]) {
		[coordinator sendMessageToBuffer:@"Help unavailable for command."];
		return;
	}
}
		
@synthesize commands;
@synthesize coordinator;
@synthesize defaultTarget;
@end
