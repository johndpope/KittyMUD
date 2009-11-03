//
//  KMCharacter.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/19/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//

#import "KMCharacter.h"
#import "NSString+KMAdditions.h"
#import "KMRoom.h"
#import "KMConnectionCoordinator.h"
#import "KMStatCopy.h"

static KMStat* defaultStats;

@implementation KMCharacter

+(void) setDefaultStats:(KMStat *)def {
	defaultStats = def;
}

+(KMStat*) defaultStats {
	return defaultStats;
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

-(void) debugPrintFlagStatus:(id)coordinator
{
	for(NSString* flag in [flags allKeys])
	{
		NSString* flagstatus;
		if([self isFlagSet:flag])
			flagstatus = @"SET";
		else
			flagstatus = @"CLEAR";
		[coordinator sendMessageToBuffer:[NSString stringWithFormat:@"Flag %@: %@", flag, flagstatus]];
	}
}

-(id)initializeWithName:(NSString *)name
{
	self = [super init];
	if(self) {
		properties = [[NSMutableDictionary alloc] init];
		[properties setObject:name forKey:@"name"];
		[properties setValue:@"`B[ `GHP`w:`c[`r$(CurHp)/`R$(MaxHp)`c]  `CMP`w:`c[`g$(CurMp)/`G$(MaxMp)`c] `YLvl:`w(`y$(Lvl)`w) `B]`x:" forKey:@"prompt"];
		if(defaultStats) {
			stats = [[[defaultStats class] alloc] init];
			[stats copyStat:defaultStats withSettings:KMStatCopySettingsAll];
		} else {
			stats = [KMStat loadFromTemplateAtPath:[@"$(DataDir)/templates/stat_template.xml" replaceAllVariables]];
		}
		flags = [[NSMutableDictionary alloc] init];
		flagbase = [[NSMutableArray alloc] init];
		[flagbase addObject:[NSNumber numberWithUnsignedLongLong:0]];
		currentbitpower = 0;
	}
	return self;
}

-(NSXMLElement*) saveToXML
{
	NSXMLElement* characterElement = [[NSXMLElement alloc] initWithName:@"character"];
	NSXMLNode* nameAttribute = [NSXMLNode attributeWithName:@"name" stringValue:[self valueForKeyPath:@"properties.name"]];
	[characterElement addAttribute:nameAttribute];
	NSXMLElement* propertiesElement = [[NSXMLElement alloc] initWithName:@"properties"];
	for(NSString* property in [[self getProperties] allKeys]) {
		if([property isEqualToString:@"name"])
			continue;
		NSXMLElement* propertyElement = [[NSXMLElement alloc] initWithName:@"property"];
		NSXMLNode* propertyNameAttribute = [NSXMLNode attributeWithName:@"key" stringValue:property];
		NSXMLNode* propertyValueAttribute = [NSXMLNode attributeWithName:@"value" stringValue:[[[self getProperties] objectForKey:property] stringValue]];
		[propertyElement addAttribute:propertyNameAttribute];
		[propertyElement addAttribute:propertyValueAttribute];
		[propertiesElement addChild:propertyElement];
	}
	[characterElement addChild:propertiesElement];
	NSXMLElement* statElement = [[self stats] saveToXML];
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
	[characterElement addChild:flagsElement];
	[characterElement addChild:statElement];
	return characterElement;
}

+(KMCharacter*) loadFromXML:(NSXMLElement*)xelem {
	NSXMLNode* nameAttribute = [xelem attributeForName:@"name"];
	KMCharacter* character = [[KMCharacter alloc] initializeWithName:[nameAttribute stringValue]];
	NSArray* propElems = [xelem elementsForName:@"properties"];
	if([propElems count] > 0) {
		NSXMLElement* propertiesElement = [propElems objectAtIndex:0];
		NSArray* propertyElements = [propertiesElement elementsForName:@"property"];
		for(NSXMLElement* propertyElement in propertyElements) {
			NSXMLNode* propertyNameElement = [propertyElement attributeForName:@"key"];
			NSXMLNode* propertyValueElement = [propertyElement attributeForName:@"value"];
			if(![[propertyNameElement stringValue] isEqualToString:@"current-room"]) {
				[character setValue:[propertyValueElement stringValue] forKeyPath:[NSString stringWithFormat:@"properties.%@",[propertyNameElement stringValue]]];
			} else {
				[character setValue:[KMRoom getRoomByName:[propertyValueElement stringValue]] forKeyPath:@"properties.current-room"];
			}
		}
	}
	NSArray* flagElems = [xelem elementsForName:@"flags"];
	if([flagElems count] > 0) {
		NSXMLElement* flagsElement = [flagElems objectAtIndex:0];
		NSArray* flagElements = [flagsElement elementsForName:@"flag"];
		for(NSXMLElement* flagElement in flagElements) {
			NSXMLNode* flagNameAttribute = [flagElement attributeForName:@"flagname"];
			NSXMLNode* isSetAttribute = [flagElement attributeForName:@"isset"];
			if([[isSetAttribute stringValue] isEqualToString:@"true"])
				[character setFlag:[flagNameAttribute stringValue]];
		}
	}
	[character setStats:[KMStat loadFromTemplateWithRootElement:xelem withType:KMStatLoadTypeSave]];
	return character;
}

-(NSString*) menuLine {
	return [[self valueForKeyPath:@"properties.name"] capitalizedString];
}

@synthesize stats;
@synthesize properties;
@synthesize flagbase;
@synthesize flags;
@synthesize currentbitpower;
@end
