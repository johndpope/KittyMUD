//
//  KMCharacter.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/19/09.
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

#import "KMCharacter.h"
#import "NSString+KMAdditions.h"
#import "KMRoom.h"
#import "KMConnectionCoordinator.h"
#import "KMServer.h"

@implementation KMCharacter

-(id)initWithName:(NSString *)name
{
	self = [super init];
	if(self) {
		[[self properties] setObject:name forKey:@"name"];
		[[self properties] setObject:@"`B[ `GHP`w:`c[`r#{c->stat('hitpoints::current')}`w/`R#{c->stat('hitpoints::maximum')}`c]  `YLvL:`w(`y#{c->stat('level')}`w) `B]`x:" forKey:@"prompt"];
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
	for(NSString* property in [[self properties] allKeys]) {
		if([property isEqualToString:@"name"])
			continue;
		NSXMLElement* propertyElement = [[NSXMLElement alloc] initWithName:@"property"];
		NSXMLNode* propertyNameAttribute = [NSXMLNode attributeWithName:@"key" stringValue:property];
		NSXMLNode* propertyValueAttribute = [NSXMLNode attributeWithName:@"value" stringValue:[[[self properties] objectForKey:property] stringValue]];
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
	KMCharacter* character = [[KMCharacter alloc] initWithName:[nameAttribute stringValue]];
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
	for(KMConnectionCoordinator* coordinator in [[[KMServer defaultServer] connectionPool] connections]) {
		if(![[coordinator valueForKeyPath:@"properties.current-character.properties.name"] caseInsensitiveCompare:name])
			return [coordinator valueForKeyPath:@"properties.current-character"];
	}
	return nil;
}

-(NSString*) menuLine {
	return [[self valueForKeyPath:@"properties.name"] capitalizedString];
}

-(NSString*) stringValue {
    return [self valueForKeyPath:@"properties.name"];
}

-(id) valueForUndefinedKey:(NSString*) key {
    if([key isEqualToString:@"room"])
        return [self valueForKeyPath:@"properties.current-room"];
    return nil;
}

@synthesize stats;
@end
