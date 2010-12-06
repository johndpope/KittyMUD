//
//  KMStat.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/20/09.
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

#import "KMStat.h"

@implementation NSXMLElement (Private)

- (id)valueForUndefinedKey:(NSString *)key
{
	return [self attributeForName:key];
}

@end

@implementation KMStat

-(id) init
{
	return [self initializeWithName:nil andValue:0];
}

-(id) initializeWithName:(NSString*)sname andValue:(int)val
{
	return [self initializeWithName:sname andAbbreviation:nil andValue:val];
}

-(id) initializeWithName:(NSString*)sname andAbbreviation:(NSString*)sabbr
{
	return [self initializeWithName:sname andAbbreviation:sabbr andValue:0];
}

-(id) initializeWithName:(NSString*)sname andAbbreviation:(NSString*)sabbr andValue:(int)val
{
	self = [super init];
	if(self) {
		[self setName:sname];
		[self setAbbreviation:(sabbr != nil ? sabbr : sname)];
		[self setStatvalue:val];
		children = [[NSMutableArray alloc] init];
		properties = [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(KMStat*) findStatWithPath:(NSString*)path
{
	NSScanner* scanner = [NSScanner scannerWithString:path];
	NSString* parentString = [[NSString alloc] init];
	NSString* childString = nil;
	[scanner scanUpToString:@"::" intoString:&parentString];
	if(![scanner isAtEnd]) {
		[scanner scanString:@"::" intoString:NULL];
		childString = [[scanner string] substringFromIndex:[scanner scanLocation]];
	}
	
	NSString* statName;
	NSString* statAbbreviation = nil;
	
	NSScanner* abbrScanner = [NSScanner scannerWithString:parentString];
	statName = [[NSString alloc] init];
	[abbrScanner scanUpToString:@"(" intoString:&statName];
	if(![abbrScanner isAtEnd]) {
		[abbrScanner scanString:@"(" intoString:NULL];
		statAbbreviation = [[NSString alloc] init];
		[abbrScanner scanUpToString:@")" intoString:&statAbbreviation];
	}
	
	if(![self hasChildren])
		return nil;
	
	NSPredicate* parentTest = [NSPredicate predicateWithFormat:@"self.name like[cd] %@ or self.abbreviation like[cd] %@ or self.abbreviation like[cd] %@", parentString, parentString,
							   statAbbreviation != nil ? statAbbreviation : @"(null)"];
	if([[children filteredArrayUsingPredicate:parentTest] count] > 0) {
		if(childString)
			return [[[children filteredArrayUsingPredicate:parentTest] objectAtIndex:0] findStatWithPath:childString];
		else
			return [[children filteredArrayUsingPredicate:parentTest] objectAtIndex:0];
	}
	else {
		for(KMStat* child in children) {
			if([child findStatWithPath:path] != nil)
				return [child findStatWithPath:path];
		}
	}
	return nil;
}

-(void) setValueOfChildAtPath:(NSString*)path withValue:(int)val
{
	if([self findStatWithPath:path])
	{
		[[self findStatWithPath:path] setStatvalue:val];
	}
	// statname(abbrname)
	// statname::childname
	NSScanner* scanner = [NSScanner scannerWithString:path];
	NSString* parentString = [[NSString alloc] init];
	NSString* childString = nil;
	[scanner scanUpToString:@"::" intoString:&parentString];
	if(![scanner isAtEnd]) {
		[scanner scanString:@"::" intoString:NULL];
		childString = [[scanner string] substringFromIndex:[scanner scanLocation]];
	}
	
	NSString* statName;
	NSString* statAbbreviation = nil;
	
	NSScanner* abbrScanner = [NSScanner scannerWithString:parentString];
	statName = [[NSString alloc] init];
	[abbrScanner scanUpToString:@"(" intoString:&statName];
	if(![abbrScanner isAtEnd]) {
		[abbrScanner scanString:@"(" intoString:NULL];
		statAbbreviation = [[NSString alloc] init];
		[abbrScanner scanUpToString:@")" intoString:&statAbbreviation];
	}
	
	if(![self hasChildren])
	{
		KMStat* parentStat = [[[self class] alloc] initializeWithName:statName andAbbreviation:(statAbbreviation ? statAbbreviation : statName) andValue:0];
		if(childString) {
			[parentStat setValueOfChildAtPath:childString withValue:val];
		} else {
			[parentStat setStatvalue:val];
		}
		[parentStat setParent:self];
		[self addChild:parentStat];
	} else {
		NSPredicate* parentTest = [NSPredicate predicateWithFormat:@"self.name like[cd] %@ or self.abbreviation like[cd] %@ or self.abbreviation like[cd] %@", statName, statName, statAbbreviation];
		if([[children filteredArrayUsingPredicate:parentTest] count] > 0) {
			if(childString)
				return [[[children filteredArrayUsingPredicate:parentTest] objectAtIndex:0] setValueOfChildAtPath:childString withValue:val];
			else
				return [[[children filteredArrayUsingPredicate:parentTest] objectAtIndex:0] setStatvalue:val];
		} else {
			KMStat* parentStat = [[[self class] alloc] initializeWithName:statName andAbbreviation:(statAbbreviation ? statAbbreviation : statName) andValue:0];
			if(childString) {
				[parentStat setValueOfChildAtPath:childString withValue:val];
			} else {
				[parentStat setStatvalue:val];
			}
			[parentStat setParent:self];
			[self addChild:parentStat];
		}
	}
}

-(int) getValueOfChildAtPath:(NSString*)path
{
	KMStat* stat = [self findStatWithPath:path];
	if(stat == nil)
		return -99999;
	return [stat statvalue];
}

-(void) addChild:(KMStat*)child
{
	NSPredicate* nameCheck = [NSPredicate predicateWithFormat:@"self.name like[cd] %@ or self.abbreviation like[cd] %@",[child name], [child abbreviation]];
	if([[children filteredArrayUsingPredicate:nameCheck] count] > 0)
		return;
	[children addObject:child];
}

-(BOOL) hasChildren
{
	if([children count] > 0)
		return YES;
	else 
		return NO;
}

+(KMStat*) loadFromTemplateAtPath:(NSString*)path
{
	return [self loadFromTemplateAtPath:path withType:KMStatLoadTypeDefault];
}

+(KMStat*) loadFromTemplateAtPath:(NSString*)path withType:(KMStatLoadType)loadType
{
	NSFileHandle* template = [NSFileHandle fileHandleForReadingAtPath:path];
	if(template == nil)
		return nil;
	return [self loadFromTemplateWithData:[template readDataToEndOfFile] withType:loadType];
}

+(KMStat*) loadFromTemplateUsingXmlDocument:(NSXMLDocument*)doc
{
	return [self loadFromTemplateUsingXmlDocument:doc withType:KMStatLoadTypeDefault];
}

+(KMStat*) loadFromTemplateUsingXmlDocument:(NSXMLDocument*)doc withType:(KMStatLoadType)loadType
{
	return [self loadFromTemplateWithRootElement:[doc rootElement] withType:loadType];
}

+(KMStat*) loadFromTemplateWithRootElement:(NSXMLElement *)root {
	return [self loadFromTemplateWithRootElement:root withType:KMStatLoadTypeDefault];
}

+(KMStat*) loadFromTemplateWithRootElement:(NSXMLElement *)root withType:(KMStatLoadType)loadType
{
	__block KMStat* main = [[self alloc] initializeWithName:@"main" andValue:0];
	if(root == nil)
		return main;
	
	NSArray* statcollection = [root elementsForName:@"statcollection"];
	if([statcollection count] == 0)
		return main;
	
	NSPredicate* mainElementPred = [NSPredicate predicateWithFormat:@"self.statname.stringValue like 'main'"];
	NSArray* mainElementA = [statcollection filteredArrayUsingPredicate:mainElementPred];
	if(![mainElementA count] > 0)
		return main;
	
	NSXMLElement* mainElement = [mainElementA objectAtIndex:0];
	if(loadType == KMStatLoadTypeAllocation) {
		NSXMLNode* allocAttribute = [mainElement valueForKey:@"alloc"];
		if(allocAttribute != nil)
			[[main properties] setObject:[NSNumber numberWithInt:[[allocAttribute stringValue] intValue]] forKey:@"allocatable"];
	}
	
	NSString* attributeToLookFor;
	
	switch(loadType) {
		case KMStatLoadTypeAllocation:
			attributeToLookFor = @"alloc";
			break;
		case KMStatLoadTypeJob:
			attributeToLookFor = @"klassreq";
			break;
		case KMStatLoadTypeRace:
			attributeToLookFor = @"bonus";
			break;
		case KMStatLoadTypeSave:
		case KMStatLoadTypeDefault:
		default:
			attributeToLookFor = @"value";
			break;
	}
	
	KMStat* (^getStat)(NSXMLElement*,KMStat*) = ^KMStat*(NSXMLElement* element, KMStat* statParent){
		KMStat* stat;
		NSXMLNode* nameAttribute = [element valueForKey:@"statname"];
		if(nameAttribute == nil)
			return nil;
		NSString* statName = [nameAttribute stringValue];
		NSXMLNode* abbreviationAttribute = [element valueForKey:@"abbr"];
		NSString* statAbbr = statName;
		if(abbreviationAttribute != nil)
			statAbbr = [abbreviationAttribute stringValue];
		int _statvalue = 0;
		BOOL changeable = NO;
		NSXMLNode* valueAttribute = [element valueForKey:attributeToLookFor];
		if(valueAttribute != nil)
			_statvalue = [[valueAttribute stringValue] intValue];
		
		stat = [[self alloc] initializeWithName:statName andAbbreviation:statAbbr andValue:0];
		if(loadType == KMStatLoadTypeAllocation) {
			[[stat properties] setObject:[NSNumber numberWithInt:_statvalue] forKey:@"allocatable"];
			NSXMLNode* changeableAttribute = [element valueForKey:@"changeable"];
			if(changeableAttribute != nil)
				changeable = [[changeableAttribute stringValue] boolValue];
		} else
			[stat setStatvalue:_statvalue];
		
		[[stat properties] setObject:[NSNumber numberWithBool:changeable] forKey:@"changeable"];
		[stat setParent:statParent];
		
		return stat;
	};
	
	__block void (^loopStat)(KMStat*,NSEnumerator*);
	
	loopStat = ^(KMStat* parentstat,NSEnumerator* enumerator){
		for(NSXMLElement* statCollectionElement in enumerator) {
			KMStat* stat = getStat(statCollectionElement, parentstat);
			NSArray* directDescendants = [statCollectionElement elementsForName:@"stat"];
			NSArray* collectionDescendants = [statCollectionElement elementsForName:@"statcollection"];
			for(NSXMLElement* descendant in directDescendants)
				[stat addChild:getStat(descendant,stat)];
			if([collectionDescendants count] > 0)
				loopStat(stat, [collectionDescendants objectEnumerator]);
			[parentstat addChild:stat];
		}
	};
	
	NSArray* statchildren = [mainElement elementsForName:@"stat"];
	NSArray* collectionchildren = [mainElement elementsForName:@"statcollection"];
	
	loopStat(main,[collectionchildren objectEnumerator]);
	
	for(NSXMLElement* mainStatChild in statchildren)
		[main addChild:getStat(mainStatChild,main)];
	
	return main;
}

+(KMStat*) loadFromTemplateWithData:(NSData*)data
{
	return [self loadFromTemplateWithData:data withType:KMStatLoadTypeDefault];
}

+(KMStat*) loadFromTemplateWithData:(NSData*)data withType:(KMStatLoadType)loadType
{
	NSXMLDocument* doc = [[NSXMLDocument alloc] initWithData:data options:0 error:NULL];
	if(doc == nil)
		return nil;
	return [self loadFromTemplateUsingXmlDocument:doc withType:loadType];
}

+(KMStat*) loadFromTemplateWithString:(NSString*)string {
	return [self loadFromTemplateWithData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

+(KMStat*) loadFromTemplateWithString:(NSString*) string withType:(KMStatLoadType)loadType {
	return [self loadFromTemplateWithData:[string dataUsingEncoding:NSUTF8StringEncoding] withType:loadType];
}

-(void) KM_debugPrintTree:(int)tabLevel
{
	return;
	NSMutableString* line = [[NSMutableString alloc] init];
	for(int i = 0; i < tabLevel; i++)
		[line appendString:@"\t"];
	[line appendFormat:@"%@(%@) = %d (Parent name = %@) (allocatable = %d) (changeable = %@)", [self name], [self abbreviation], [self statvalue], [[self parent] name], [[[self properties] objectForKey:@"allocatable"] intValue],
	 [[[self properties] objectForKey:@"changeable"] boolValue] ? @"YES" : @"NO"];
	OCLog(@"kittymud",debug,@"%@", line);
	if([self hasChildren]) {
		NSArray* child = [self getChildren];
		for(NSUInteger c = 0; c < [child count]; c++)
			[[child objectAtIndex:c] KM_debugPrintTree:(tabLevel + 1)];
	}
}


+(id)customLoader:(NSXMLElement*)xelem withContext:(void*)context
{
	KMStatLoadType type = *(KMStatLoadType*)context;
	return [KMStat loadFromTemplateWithRootElement:xelem withType:type];
}

-(NSArray*) getChildren {
	return (NSArray*)children;
}

-(NSXMLElement*) saveToXML {
	NSString* mainName;
	if([self hasChildren])
		mainName = @"statcollection";
	else {
		mainName = @"stat";
	}
	NSXMLElement* mainElement = [[NSXMLElement alloc] initWithName:mainName];
	NSXMLNode* nameAttribute = [NSXMLNode attributeWithName:@"statname" stringValue:[self name]];
	NSXMLNode* abbreviationAttribute = [NSXMLNode attributeWithName:@"abbr" stringValue:[self abbreviation]];
	NSXMLNode* valueAttribute = [NSXMLNode attributeWithName:@"value" stringValue:[[NSNumber numberWithInt:[self statvalue]] stringValue]];
	[mainElement addAttribute:nameAttribute];
	[mainElement addAttribute:abbreviationAttribute];
	[mainElement addAttribute:valueAttribute];
	if([self hasChildren]) {
		for(KMStat* child in [self getChildren]) {
			[mainElement addChild:[child saveToXML]];
		}
	}
	return mainElement;
}

-(void) copyStat:(KMStat*)stat
{
	[self copyStat:stat withSettings:KMStatCopySettingsAllExceptName];
}

-(void) copyStat:(KMStat*)stat withSettings:(KMStatCopySettings)settings
{
	if(!stat)
		return;
	
	if(settings & KMStatCopySettingsName)
	{
		[self setName:[stat name]];
		[self setAbbreviation:[stat abbreviation]];
	}
	if(settings & KMStatCopySettingsValue)
		[self setStatvalue:[stat statvalue]];
	if(settings & KMStatCopySettingsChangeable && [stat valueForKeyPath:@"properties.changeable"])
		[[self properties] setObject:[[stat properties] objectForKey:@"changeable"] forKey:@"changeable"];
	if(settings & KMStatCopySettingsAllocatable && [stat valueForKeyPath:@"properties.allocatable"])
		[[self properties] setObject:[[stat properties] objectForKey:@"allocatable"] forKey:@"allocatable"];
	if([stat hasChildren]) {
		for(KMStat* child in [stat getChildren]) {
			if([child name] == nil || [child abbreviation] == nil)
				continue;
			KMStat* mychild = [self findStatWithPath:[child name]];
			BOOL toAdd = NO;
			if(!mychild) {
				mychild = [[[child class] alloc] init];
				toAdd = YES;
			}
			[mychild copyStat:child withSettings:settings];
			if(toAdd)
				[self addChild:mychild];
		}
	}
}


@synthesize statvalue;
@synthesize name;
@synthesize parent;
@synthesize abbreviation;
@synthesize children;
@end
