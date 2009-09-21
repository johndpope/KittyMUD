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
	return [self initializeWithValue:0];
}

-(id) initializeWithValue:(int)val
{
	return [self initializeWithName:nil andValue:val];
}

-(id) initializeWithName:(NSString*)sname andValue:(int)val
{
	self = [super init];
	if(self) {
		[self setName:sname];
		[self setStatvalue:val];
		children = [[NSMutableArray alloc] init];
		properties = [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(KMStat*) findStatWithPath:(NSString*)path
{
	RKRegex* pathr = [[RKRegex alloc] initWithRegexString:@"(?<parent>[^:]*)(::(?<children>.*))*" options:RKCompileNoOptions];
	if([pathr matchesCharacters:[path cStringUsingEncoding:NSASCIIStringEncoding] length:[path length] inRange:NSMakeRange(0,[path length]) options:RKMatchNoOptions]) {
		if(![self hasChildren])
			return nil;
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
		NSPredicate* parentTest = [NSPredicate predicateWithFormat:@"self.name like[cd] %@", parentString];
		if([[children filteredArrayUsingPredicate:parentTest] count] > 0) {
			if(child.length > 0)
				return [[[children filteredArrayUsingPredicate:parentTest] objectAtIndex:0] findStatWithPath:[path substringWithRange:child]];
			else
				return [[children filteredArrayUsingPredicate:parentTest] objectAtIndex:0];
		}
		else 
			return nil;
	}
	return nil;
}

-(void) setValueOfChildAtPath:(NSString*)path withValue:(int)val
{
	if([self findStatWithPath:path])
	{
		[[self findStatWithPath:path] setStatvalue:val];
	}
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
		if(![self hasChildren])
		{
			KMStat* parentStat = [[KMStat alloc] initializeWithName:parentString andValue:0];
			if(child.length > 0) {
				[parentStat setValueOfChildAtPath:[path substringWithRange:child] withValue:val];
			} else {
				[parentStat setStatvalue:val];
			}
			[parentStat setParent:self];
			[self addChild:parentStat];
		} else {
			NSPredicate* parentTest = [NSPredicate predicateWithFormat:@"self.name like[cd] %@", parentString];
			if([[children filteredArrayUsingPredicate:parentTest] count] > 0) {
				if(child.length > 0)
					return [[[children filteredArrayUsingPredicate:parentTest] objectAtIndex:0] setValueOfChildAtPath:[path substringWithRange:child] withValue:val];
				else
					return [[[children filteredArrayUsingPredicate:parentTest] objectAtIndex:0] setStatvalue:val];
			} else {
				KMStat* parentStat = [[KMStat alloc] initializeWithName:parentString andValue:0];
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
	NSPredicate* nameCheck = [NSPredicate predicateWithFormat:@"self.name like[cd] %@",[child name]];
	if([[children filteredArrayUsingPredicate:nameCheck] count] > 0)
		return;
	[children addObject:child];
}

-(NSMutableDictionary*) getProperties
{
	return properties;
}

-(void) setProperties:(NSMutableDictionary *)value
{
	return; // no-op properties is read-only
}

-(NSArray*) getChildren
{
	return [[NSArray alloc] initWithArray:children];
}

-(void) setChildren:(NSArray*)value
{
	return;
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
	__block KMStat* main = [[KMStat alloc] initializeWithName:@"main" andValue:0];
	if(doc == nil)
		return main;
	
	NSArray* statcollection = [[doc rootElement] elementsForName:@"statcollection"];
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
		int _statvalue = 0;
		BOOL changeable = NO;
		NSXMLNode* valueAttribute = [element valueForKey:attributeToLookFor];
		if(valueAttribute != nil)
			_statvalue = [[valueAttribute stringValue] intValue];
		
		stat = [[KMStat alloc] initializeWithName:statName andValue:0];
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
	[line appendFormat:@"%@ = %d (Parent name = %@) (allocatable = %d) (changeable = %@)", [self name], [self statvalue], [[self parent] name], [[[self getProperties] objectForKey:@"allocatable"] intValue],
	 [[[self getProperties] objectForKey:@"changeable"] boolValue] ? @"YES" : @"NO"];
	if([self hasChildren]) {
		NSArray* child = [self getChildren];
		for(int c = 0; c < [child count]; c++)
			[[child objectAtIndex:c] debugPrintTree:(tabLevel + 1)];
	}
}

@synthesize statvalue;
@synthesize name;
@synthesize parent;

@end
