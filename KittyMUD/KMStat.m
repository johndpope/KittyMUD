//
//  KMStat.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "KMStat.h"
#import <RegexKit/RegexKit.h>

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
	// This regular expression is used to split stat names from abbreviations when they are created in code (form: name(abbr))
	RKRegex* splitr = [[RKRegex alloc] initWithRegexString:@"(?<statname>\\w+)(\\((?<abbrname>\\w+)\\))?" options:RKCompileNoOptions];
	
	// This regular expression is used to split the path of the stat using the :: separator.  We use it as a recursive regular expression,
	// meaning that for a stat path a::b::c, we would use this regular expression three times.
	// First pass: parent=a, children=b::c
	// Second pass: parent=b, children=c
	// Third pass: parent=c
	RKRegex* pathr = [[RKRegex alloc] initWithRegexString:@"(?<parent>[^:]*)(::(?<children>.*))*" options:RKCompileNoOptions];
	
	// If we have no children, we know were not going to find one, so return nil.
	if(![self hasChildren])
		return nil;
	
	// Check to make sure the path were given is a valid stat path.
	if([pathr matchesCharacters:[path cStringUsingEncoding:NSASCIIStringEncoding] length:[path length] inRange:NSMakeRange(0,[path length]) options:RKMatchNoOptions]) {
		NSRange parentr = [pathr rangeForCharacters:[path cStringUsingEncoding:NSASCIIStringEncoding]
										   length:[path length]
										  inRange:NSMakeRange(0,[path length])
									 captureIndex:[pathr captureIndexForCaptureName:@"parent"]
										  options:RKMatchNoOptions];
		NSRange child = [pathr rangeForCharacters:[path cStringUsingEncoding:NSASCIIStringEncoding]
										   length:[path length]
										  inRange:NSMakeRange(0,[path length])
									 captureIndex:[pathr captureIndexForCaptureName:@"children"]
										  options:RKMatchNoOptions];
		// Get the string representing the name of the parent from the match.
		NSString* parentString = [path substringWithRange:parentr];
		NSString* statAbbreviation = nil;
		
		NSRange sname = [splitr rangeForCharacters:[parentString cStringUsingEncoding:NSASCIIStringEncoding]
											length:[parentString length]
										   inRange:NSMakeRange(0,[parentString length])
									  captureIndex:[splitr captureIndexForCaptureName:@"statname"]
										   options:RKMatchNoOptions];
		NSRange sabbr = [splitr rangeForCharacters:[parentString cStringUsingEncoding:NSASCIIStringEncoding]
											length:[parentString length]
										   inRange:NSMakeRange(0,[parentString length])
									  captureIndex:[splitr captureIndexForCaptureName:@"abbrname"]
										   options:RKMatchNoOptions];
		NSString* parentName = [parentString substringWithRange:sname];
		if(sabbr.length > 0)
			statAbbreviation = [parentString substringWithRange:sabbr];
		NSPredicate* parentTest = [NSPredicate predicateWithFormat:@"self.name like[cd] %@ or self.abbreviation like[cd] %@ or self.abbreviation like[cd] %@", parentName, parentName,
								   statAbbreviation != nil ? statAbbreviation : @"(null)"];
		if([[children filteredArrayUsingPredicate:parentTest] count] > 0) {
			if(child.length > 0)
				return [[[children filteredArrayUsingPredicate:parentTest] objectAtIndex:0] findStatWithPath:[path substringWithRange:child]];
			else
				return [[children filteredArrayUsingPredicate:parentTest] objectAtIndex:0];
		}
		else {
			for(KMStat* child in children) {
				if([child findStatWithPath:path] != nil)
					return [child findStatWithPath:path];
			}
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
	RKRegex* splitr = [[RKRegex alloc] initWithRegexString:@"(?<statname>\\w+)(\\((?<abbrname>\\w+)\\))?" options:RKCompileNoOptions];
	RKRegex* pathr = [[RKRegex alloc] initWithRegexString:@"(?<parent>[^:]*)(::(?<children>.*))*" options:RKCompileNoOptions];
	if([pathr matchesCharacters:[path cStringUsingEncoding:NSASCIIStringEncoding] length:[path length] inRange:NSMakeRange(0,[path length]) options:RKMatchNoOptions]) {
		NSRange parentr = [pathr rangeForCharacters:[path cStringUsingEncoding:NSASCIIStringEncoding]
											 length:[path length]
											inRange:NSMakeRange(0,[path length])
									   captureIndex:[pathr captureIndexForCaptureName:@"parent"]
											options:RKMatchNoOptions];
		NSRange child = [pathr rangeForCharacters:[path cStringUsingEncoding:NSASCIIStringEncoding]
										   length:[path length]
										  inRange:NSMakeRange(0,[path length])
									 captureIndex:[pathr captureIndexForCaptureName:@"children"]
										  options:RKMatchNoOptions];
		NSString* parentString = [path substringWithRange:parentr];	
		NSString* statName;
		NSString* statAbbreviation = nil;
		NSRange sname = [splitr rangeForCharacters:[parentString cStringUsingEncoding:NSASCIIStringEncoding]
											length:[parentString length]
										   inRange:NSMakeRange(0,[parentString length])
									  captureIndex:[splitr captureIndexForCaptureName:@"statname"]
										   options:RKMatchNoOptions];
		NSRange sabbr = [splitr rangeForCharacters:[parentString cStringUsingEncoding:NSASCIIStringEncoding]
											length:[parentString length]
										   inRange:NSMakeRange(0,[parentString length])
									  captureIndex:[splitr captureIndexForCaptureName:@"abbrname"]
										   options:RKMatchNoOptions];
		
		statName = [parentString substringWithRange:sname];
		
		if(sabbr.length != 0)
			statAbbreviation = [parentString substringWithRange:sabbr];
	
		if(![self hasChildren])
		{
			KMStat* parentStat = [[KMStat alloc] initializeWithName:statName andAbbreviation:(statAbbreviation ? statAbbreviation : statName) andValue:0];
			if(child.length > 0) {
				[parentStat setValueOfChildAtPath:[path substringWithRange:child] withValue:val];
			} else {
				[parentStat setStatvalue:val];
			}
			[parentStat setParent:self];
			[self addChild:parentStat];
		} else {
			NSPredicate* parentTest = [NSPredicate predicateWithFormat:@"self.name like[cd] %@ or self.abbreviation like[cd] %@ or self.abbreviation like[cd] %@", statName, statName, statAbbreviation];
			if([[children filteredArrayUsingPredicate:parentTest] count] > 0) {
				if(child.length > 0)
					return [[[children filteredArrayUsingPredicate:parentTest] objectAtIndex:0] setValueOfChildAtPath:[path substringWithRange:child] withValue:val];
				else
					return [[[children filteredArrayUsingPredicate:parentTest] objectAtIndex:0] setStatvalue:val];
			} else {
				KMStat* parentStat = [[KMStat alloc] initializeWithName:statName andAbbreviation:(statAbbreviation ? statAbbreviation : statName) andValue:0];
				if(child.length > 0) {
					[parentStat setValueOfChildAtPath:[path substringWithRange:child] withValue:val];
				} else {
					[parentStat setStatvalue:val];
				}
				[parentStat setParent:self];
				[self addChild:parentStat];
			}
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
	__block KMStat* main = [[KMStat alloc] initializeWithName:@"main" andValue:0];
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
			[[main getProperties] setObject:[NSNumber numberWithInt:[[allocAttribute stringValue] intValue]] forKey:@"allocatable"];
	}
	
	NSString* attributeToLookFor;
	
	switch(loadType) {
		case KMStatLoadTypeAllocation:
			attributeToLookFor = @"alloc";
			break;
		case KMStatLoadTypeJob:
			attributeToLookFor = @"jobreq";
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
		
		stat = [[KMStat alloc] initializeWithName:statName andAbbreviation:statAbbr andValue:0];
		if(loadType == KMStatLoadTypeAllocation) {
			[[stat getProperties] setObject:[NSNumber numberWithInt:_statvalue] forKey:@"allocatable"];
			NSXMLNode* changeableAttribute = [element valueForKey:@"changeable"];
			if(changeableAttribute != nil)
				changeable = [[changeableAttribute stringValue] boolValue];
		} else
			[stat setStatvalue:_statvalue];
		
		[[stat getProperties] setObject:[NSNumber numberWithBool:changeable] forKey:@"changeable"];
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

-(void) debugPrintTree:(int)tabLevel
{
	NSMutableString* line = [[NSMutableString alloc] init];
	for(int i = 0; i < tabLevel; i++)
		[line appendString:@"\t"];
	[line appendFormat:@"%@(%@) = %d (Parent name = %@) (allocatable = %d) (changeable = %@)", [self name], [self abbreviation], [self statvalue], [[self parent] name], [[[self getProperties] objectForKey:@"allocatable"] intValue],
	 [[[self getProperties] objectForKey:@"changeable"] boolValue] ? @"YES" : @"NO"];
	NSLog(@"%@", line);
	if([self hasChildren]) {
		NSArray* child = [self getChildren];
		for(int c = 0; c < [child count]; c++)
			[[child objectAtIndex:c] debugPrintTree:(tabLevel + 1)];
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
@synthesize statvalue;
@synthesize name;
@synthesize parent;

@synthesize abbreviation;
@synthesize properties;
@synthesize children;
@end
