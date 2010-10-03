//
//  KMPower.m
//  KittyMUD
//
//  Created by Michael Tindal on 1/17/10.
//  Copyright 2010 Michael Tindal. All rights reserved.
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

#import "KMPower.h"
#import "KMCommandInterpreter.h"
#import "KMPlayingState.h"
#import "KMExtensibleDataLoader.h"

@implementation KMPower


+(void) executePower:(id)coordinator withArgs:(NSArray*)args {
	NSArray* commandmakeup = [[coordinator getInputBuffer] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSString* commandName = [commandmakeup objectAtIndex:0];
#pragma unused(args)
#pragma unused(commandName)
	return;
}

+(KMPower*) createPowerWithRootElement:(NSXMLElement*)root {
	KMPowerType type;
	KMPowerUsage usage;
	NSString* myId;
	NSString* displayName;
	XiNode* definition;
	NSArray* defargs;
	NSMutableDictionary* variables;
	KMPowerActionType action;
	NSString* command;
	XiNode* usageTest = nil;
	NSArray* keywords = nil;
	BOOL hasSpecialUsage = NO;

	NSXMLNode* usageAttribute = [root attributeForName:@"usage"];
	NSString* usageName = [usageAttribute stringValue];
	usage = KMPowerEncounter;
	if([usageName hasPrefix:@"atwill"]) {
		usage = KMPowerAtWill;
	} else if([usageName hasPrefix:@"encounter"]) {
		usage = KMPowerEncounter;
	} else if([usageName hasPrefix:@"daily"]) {
		usage = KMPowerDaily;
	}
	if([usageName hasSuffix:@"[special]"]) {
		hasSpecialUsage = YES;
		NSXMLElement* usgElem = [[root elementsForName:@"usage"] objectAtIndex:0];
		NSXMLNode* testAttribute = [usgElem attributeForName:@"test"];
		NSString* usageText = [testAttribute stringValue];
		if([usageText isEqualToString:@":[text]"]) {
			usageText = [usgElem stringValue];
		}
		usageTest = [XiNode createNodeFromSource:usageText];
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

	NSXMLElement* typeElem = [[root elementsForName:@"type"] objectAtIndex:0];
	NSString* typeText = [typeElem stringValue];
	if([typeText isEqualToString:@"feature"])
		type = KMPowerFeatureType;
	else if([typeText isEqualToString:@"attack"])
		type = KMPowerAttackType;
	else if([typeText isEqualToString:@"utility"])
		type = KMPowerUtilityType;
	NSArray* variableElems = [root elementsForName:@"variable"];
	NSMutableDictionary* rawVariables = [NSMutableDictionary dictionary];
	for(NSXMLElement* elem in variableElems) {
		NSXMLNode* nameAttribute = [elem attributeForName:@"name"];
		NSXMLNode* defAttribute = [elem attributeForName:@"def"];
		[rawVariables setObject:[XiNode createNodeFromSource:[defAttribute stringValue]] forKey:[nameAttribute stringValue]];
	}
	
	variables = rawVariables;
	
	defargs = nil;
	NSArray* argsArray = [root elementsForName:@"args"];
	NSXMLElement* args = [argsArray count] ? [argsArray objectAtIndex:0] : nil;
	if(args) {
		NSXMLNode* namesAttribute = [args attributeForName:@"names"];
		defargs = [[namesAttribute stringValue] componentsSeparatedByString:@","];
	}
	
	NSArray* keyArray = [root elementsForName:@"keywords"];
	NSXMLElement* keys = [keyArray count] ? [keyArray objectAtIndex:0] : nil;
	if(keys) {
		keywords = [[keys stringValue] componentsSeparatedByString:@","];
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
	definition = [XiNode createNodeFromSource:defText];

	NSInteger level = 0;
	NSArray* elems = [root elementsForName:@"level"];
	if([elems count]) {
		NSXMLElement* lvl = [elems objectAtIndex:0];
		level = [[lvl stringValue] intValue];
	}
	
	KMPower* power = [[self alloc] init];
	power.type = type;
	power.usage = usage;
	power.myId = myId;
	power.displayName = displayName;
	power.definition = definition;
	power.defargs = defargs;
	power.variables = variables;
	power.action = action;
	power.command = command;
	power.level = level;
	power.hasSpecialUsage = hasSpecialUsage;
	power.usageTest = usageTest;
	power.keywords = keywords;
	return power;
}

-(BOOL) hasKeyword:(NSString*)keyword {
	return [keywords containsObject:keyword];
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
@synthesize level;
@synthesize usageTest;
@synthesize hasSpecialUsage;
@synthesize keywords;
@end

KMDefineEnum(KM,PowerType,KM_POWER_TYPE);
KMDefineEnum(KM,PowerUsage,KM_POWER_USAGE);
KMDefineEnum(KM,PowerActionType,KM_POWER_ACTION_TYPE);