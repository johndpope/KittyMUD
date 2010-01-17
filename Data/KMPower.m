//
//  KMPower.m
//  KittyMUD
//
//  Created by Michael Tindal on 1/17/10.
//  Copyright 2010 Michael Tindal. All rights reserved.
//

#import "KMPower.h"
#import "KMCommandInterpreter.h"
#import "KMPlayingState.h"
#import "KMExtensibleDataLoader.h"

@implementation KMPower

+(void) executePower:(id)coordinator withArgs:(NSArray*)args {
	NSArray* commandmakeup = [[coordinator getInputBuffer] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSString* commandName = [commandmakeup objectAtIndex:0];
	
	return;
}

+(KMPower*) createPowerWithRootElement:(NSXMLElement*)root {
	KMPowerType type;
	KMPowerUsage usage;
	NSString* myId;
	NSString* displayName;
	ECSNode* definition;
	int defargs;
	NSArray* variables;
	KMPowerActionType action;
	NSString* command;

	NSXMLNode* usageAttribute = [root attributeForName:@"usage"];
	NSString* usageName = [usageAttribute stringValue];
	usage = KMPowerEncounter;
	if([usageName isEqualToString:@"atwill"]) {
		usage = KMPowerAtWill;
	} else if([usageName isEqualToString:@"encounter"]) {
		usage = KMPowerEncounter;
	} else if([usageName isEqualToString:@"daily"]) {
		usage = KMPowerDaily;
	}	

	NSXMLElement* idElem = [[root elementsForName:@"id"] objectAtIndex:0];
	myId = [idElem stringValue];
	NSXMLElement* name = [[root elementsForName:@"name"] objectAtIndex:0];
	displayName = [name stringValue];
	NSXMLElement* act = [[root elementsForName:@"action"] objectAtIndex:0];
	NSXMLNode* actAttribute = [act attributeForName:@"type"];
	NSString* actText = [actAttribute stringValue];
	action = KMPowerStandardAction;
	if([actText isEqualToString:@"minor"]) {
		action = KMPowerMinorAction;
	} else if([actText isEqualToString:@"move"]) {
		action = KMPowerMoveAction;
	} else if([actText isEqualToString:@"free"]) {
		action = KMPowerFreeAction;
	} else if([actText isEqualToString:@"standard"]) {
		action = KMPowerStandardAction;
	} else if([actText isEqualToString:@"immediateinterrupt"]) {
		action = KMPowerImmediateInterrupt;
	} else if([actText isEqualToString:@"immediatereaction"]) {
		action = KMPowerImmediateReaction;
	} else if([actText isEqualToString:@"no"]) {
		action = KMPowerNoAction;
	}

	NSArray* variableElems = [root elementsForName:@"variable"];
	NSMutableArray* rawVariables = [NSMutableArray array];
	for(NSXMLElement* elem in variableElems) {
		NSXMLNode* defAttribute = [elem attributeForName:@"def"];
		[rawVariables addObject:[ECSNode createNodeFromSource:[defAttribute stringValue]]];
	}
	
	variables = rawVariables;
	
	defargs = 0;
	NSArray* argsArray = [root elementsForName:@"args"];
	NSXMLElement* args = [argsArray count] ? [argsArray objectAtIndex:0] : nil;
	if(args) {
		NSXMLNode* namesAttribute = [args attributeForName:@"names"];
		defargs = [[[namesAttribute stringValue] componentsSeparatedByString:@","] count];
	}
	
	NSXMLElement* cmd = [[root elementsForName:@"command"] objectAtIndex:0];
	command = @"";
	if(cmd) {
		command = [cmd stringValue];
		KMGetInterpreterForState(KMPlayingState,commandInterpreter);
		[(KMCommandInterpreter*)commandInterpreter registerCommand:self selector:@selector(executePower:withArgs:) withName:command andOptionalArguments:[NSArray arrayWithObject:@"args"] andAliases:nil andFlags:nil withMinimumLevel:1];
		[(KMCommandInterpreter*)commandInterpreter registerCommandHelp:command usingShortText:[NSString stringWithFormat:@"Uses your %@ power.",displayName] withLongTextFile:nil];
	}
	NSXMLElement* def = [[root elementsForName:@"definition"] objectAtIndex:0];
	NSXMLNode* defAttribute = [def attributeForName:@"def"];
	NSString* defText = [defAttribute stringValue];
	if([defText isEqualToString:@":[text]"]) {
		defText = [def stringValue];
	}
	definition = [ECSNode createNodeFromSource:defText usingFileName:[KMExtensibleDataLoader currentFileName]];

	KMPower* power = [[KMPower alloc] init];
	power.type = type;
	power.usage = usage;
	power.myId = myId;
	power.displayName = displayName;
	power.definition = definition;
	power.defargs = defargs;
	power.variables = variables;
	power.action = action;
	power.command = command;
	return power;
}

@synthesize type;
@synthesize usage;
@synthesize myId;
@synthesize displayName;
@synthesize definition;
@synthesize defargs;
@synthesize variables;
@synthesize action;
@synthesize command;
@end
