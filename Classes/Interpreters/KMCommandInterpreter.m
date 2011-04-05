//
//  KMCommandInterpreter.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/6/09.
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

#import "KMCommandInterpreter.h"
#import "KMConnectionCoordinator.h"
#import "KMCharacter.h"
#import "KMState.h"
#import "KMServer.h"
#import "NSString+KMAdditions.h"
#import <objc/runtime.h>

@interface KMCommandInterpreter ()

-(void) KM_registerLogic:(Class)clogic asDefaultTarget:(BOOL)dt withRealTarget:(id)target;

@end

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

-(void) registerLogic:(Class)clogic asDefaultTarget:(BOOL)dt {
	[self KM_registerLogic:clogic asDefaultTarget:dt withRealTarget:nil];
}

-(void) KM_registerLogic:(Class)clogic asDefaultTarget:(BOOL)dt withRealTarget:(id)target
{
	if(!class_conformsToProtocol(clogic, @protocol(KMCommandInterpreterLogic)))
		return;
	id<KMCommandInterpreterLogic> logic;
	if(!target) 
		logic = [[clogic alloc] initWithCommandInterpreter:self];
	else
		logic = target;
	if(class_getSuperclass(clogic))
		[self KM_registerLogic:class_getSuperclass(clogic) asDefaultTarget:NO withRealTarget:logic];
	unsigned int count;
	Method* classMethods = class_copyMethodList(clogic, &count);
	if(count == 0)
		return;
	NSMutableDictionary* classMethodD = [[NSMutableDictionary alloc] init];
	for(NSUInteger i = 0; i < count; i++) {
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
	if(!target)
		[myLogics addObject:NSStringFromClass(clogic)];
}	

-(void) registerCommandHelp:(NSString*)name usingShortText:(NSString*)shorttext withLongTextFile:(NSString*)longtextname {
	KMCommandInfo* command = [self KM_findCommandByName:name];
	if(!command)
		return;
	[command setHelp:[[NSMutableDictionary alloc] initWithObjectsAndKeys:shorttext,@"short",longtextname,@"long",nil]];
}

-(void)registerCommand:(id)target selector:(SEL)commandSelector withName:(NSString*)name andOptionalArguments:(NSArray*)optional andAliases:(NSArray*)aliases andFlags:(NSArray*)cflags withMinimumLevel:(int)level
{
	KMCommandInfo* cmd = [self KM_findCommandByName:name];
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
	NSArray* commandmakeup = [[coordinator inputBuffer] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSString* commandName = [commandmakeup objectAtIndex:0];
	KMCommandInfo* command = [self KM_findCommandByName:[commandName lowercaseString]];
	
	if(command == NULL)
	{
		[coordinator sendMessageToBuffer:@"Unknown command entered."];
		return;
	}
	
	if([commandmakeup count] > 1 && [[commandmakeup objectAtIndex:1] isEqualToString:@"-help"] && [self KM_validateInput:command forCoordinator:coordinator onlyFlagsAndLevel:YES]) {
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
	if(![self KM_validateInput:command forCoordinator:coordinator onlyFlagsAndLevel:NO])
	{
		[coordinator sendMessageToBuffer:@"Unknown command entered."];
		return;
	}
	NSMethodSignature* sig = [[[command target] class] instanceMethodSignatureForSelector:NSSelectorFromString([command method])];
	NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
	[invocation setTarget:[command target]];
	[invocation setSelector:NSSelectorFromString([command method])];
	[invocation setArgument:&coordinator atIndex:2];
    if(([commandmakeup count] - 1) > ([sig numberOfArguments] - 3)) {
        NSArray* extra = [commandmakeup subarrayWithRange:NSMakeRange([sig numberOfArguments] - 3,[commandmakeup count] - ([sig numberOfArguments] - 3))];
        NSMutableArray* new = [NSMutableArray arrayWithArray:[commandmakeup subarrayWithRange:NSMakeRange(0,([sig numberOfArguments] - 3))]];
        [new addObject:[extra componentsJoinedByString:@" "]];
        commandmakeup = new;
    }
	for(NSUInteger i = 1; i < [commandmakeup count]; i++) {
		__strong char* argType = method_copyArgumentType(class_getInstanceMethod([[command target] class], NSSelectorFromString([command method])), (unsigned int)(i + 2));
		if(!strcmp(argType,"i")) {
			__strong int num = [[commandmakeup objectAtIndex:i] intValue];
			[invocation setArgument:&num atIndex:(NSInteger)(i+2)];
		} else if(!strcmp(argType,"{NSArray=#}")) {
			NSArray* rest = [commandmakeup subarrayWithRange:NSMakeRange(i, [commandmakeup count]-i)];
			[invocation setArgument:&rest atIndex:(NSInteger)(i+2)];
			break;
		} else {
			id arg = [commandmakeup objectAtIndex:i];
			[invocation setArgument:&arg atIndex:(NSInteger)(i+2)];
		}
	}
	KMGetStateFromCoordinator(state);
	[invocation invoke];
	[super interpret:coordinator withOldState:state];
}

-(BOOL) KM_validateInput:(KMCommandInfo*)command forCoordinator:(id)coordinator onlyFlagsAndLevel:(BOOL)ofl
{
	Method m = class_getInstanceMethod([[command target] class], NSSelectorFromString([command method]));
	unsigned int numArgs = method_getNumberOfArguments(m);
	NSArray* commandmakeup = [[coordinator inputBuffer] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if(!ofl) {
		NSUInteger numOpt = [[command optArgs] count];
		if([commandmakeup count] < (numArgs - 3 - numOpt)) {
			[coordinator sendMessage:@"%d arguments expected, %d gotten", numArgs, [commandmakeup count]];
			return NO;
		}
	}
	if([command cmdflags]) {
		for(NSString* flag in [command cmdflags]) {
			if(![[coordinator valueForKeyPath:@"properties.current-character"] isFlagSet:flag] && ![coordinator isFlagSet:flag]) {
				return NO;
			}
		}
	}
	KMCharacter* character = [[coordinator properties] objectForKey:@"current-character"];
	if([[[character stats] findStatWithPath:@"level"] statvalue] < [command minLevel])
		return NO;
	return YES;
}

-(KMCommandInfo*) KM_findCommandByName:(NSString*)name
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
	KMCommandInfo* cmd = [self KM_findCommandByName:command];
	if(!cmd || ![self KM_validateInput:cmd forCoordinator:coordinator onlyFlagsAndLevel:YES]) {
		[coordinator sendMessageToBuffer:@"Unknown command."];
		return;
	}
	if(![[cmd help] objectForKey:@"long"]) {
        if([[cmd help] objectForKey:@"short"]) {
            [coordinator sendMessageToBuffer:[[cmd help] objectForKey:@"short"]];
        } else
            [coordinator sendMessageToBuffer:@"Help unavailable for command."];
		return;
	} else {
        NSFileHandle* fh = [NSFileHandle fileHandleForReadingAtPath:[NSString stringWithFormat:[@"$(BundleDir)/lib/help/%@" replaceAllVariables],[[cmd help] objectForKey:@"long"]]];
        NSData* data = [fh readDataToEndOfFile];
        [coordinator sendMessageToBuffer:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    }
}

CHELP(rebuildlogics,@"Rebuilds the logics for all command interpreters in use at the time.  Used when soft rebooting with changed commands.",nil)
CIMPL(rebuildlogics,rebuildlogics:,nil,nil,@"admin",1) {
	KMConnectionCoordinator* tc = coordinator;
	for(KMConnectionCoordinator* coord in [[[KMServer defaultServer] connectionPool] connections]) {
		coordinator = coord;
		KMGetInterpreterForCoordinator(interpreter);
		if([interpreter isKindOfClass:[KMCommandInterpreter class]]) {
			[(KMCommandInterpreter*)interpreter KM_rebuildLogics:coord];
		}
	}
	coordinator = tc;
}

CIMPL(displaycommand,displaycommand:command:,nil,nil,@"staff",1) command:(NSString*)command {
	KMCommandInfo* cmd = [self KM_findCommandByName:command];
	if(cmd == nil) {
		[coordinator sendMessageToBuffer:@"No command found."];
	}
	[coordinator sendMessageToBuffer:@"Command %@, Optional Arguments: %d, Flags Required: %d",[cmd name], [[cmd optArgs] count], [[cmd cmdflags] count]];
}

-(void) KM_rebuildLogics:(id)coordinator {
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
@synthesize defaultTarget;
@synthesize logics;
@synthesize myLogics;
@end
