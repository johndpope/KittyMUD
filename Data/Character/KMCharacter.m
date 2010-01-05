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
#import "KMServer.h"

@implementation KMCharacter

-(id)initializeWithName:(NSString *)name
{
	self = [super init];
	if(self) {
		[[self getProperties] setObject:name forKey:@"name"];
		[[self getProperties] setObject:@"`B[ `GHP`w:`c[`r$(CurHp)/`R$(MaxHp)`c]  `CMP`w:`c[`g$(CurMp)/`G$(MaxMp)`c] `YLvl:`w(`y$(Lvl)`w) `B]`x:" forKey:@"prompt"];
		stats = [KMStat loadFromTemplateAtPath:[@"$(DataDir)/templates/stat_template.xml" replaceAllVariables]];
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

+(KMCharacter*) characterForName:(NSString*)name {
	for(KMConnectionCoordinator* coordinator in [[[KMServer getDefaultServer] getConnectionPool] connections]) {
		if(![[coordinator valueForKeyPath:@"properties.current-character.properties.name"] caseInsensitiveCompare:name])
			return [coordinator valueForKeyPath:@"properties.current-character"];
	}
	return nil;
}

-(NSString*) menuLine {
	return [[self valueForKeyPath:@"properties.name"] capitalizedString];
}

@synthesize stats;
@end
