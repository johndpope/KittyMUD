//
//  KMDataManager.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/3/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMDataManager.h"


@implementation KMDataManager

-(id)init
{
	self = [super init];
	if(self) {
		tagReferences = [[NSMutableDictionary alloc] init];
		attributeReferences = [[NSMutableDictionary alloc] init];
		loadStats = NO;
		statKey = nil;
	}
	return self;
}

-(void)registerTag:(NSString*)tag forKey:(NSString*)key
{
	[tagReferences setObject:key forKey:tag];
}

-(void)registerTag:(NSString*)tag,...
{
	va_list args;
	va_start(args,tag);
	NSMutableDictionary* attributes = [[NSMutableArray alloc] init];
	id attribute,key;
	while(attribute = va_arg(args,id))
	{
		key = va_arg(args,id);
		[attributes setObject:key forKey:attribute];
	}
	va_end(args);
	[attributeReferences setObject:attributes forKey:tag];
}	

-(void)registerStatKey:(NSString*)key
{
	statKey = [key copy];
}

-(void)enableStatLoad
{
	loadStats = YES;
}

-(void)disableStatLoad
{
	loadStats = NO;
}

-(void)loadFromPath:(NSString*)path toObject:(id*)object
{
	NSFileHandle* fh = [NSFileHandle fileHandleForReadingAtPath:path];
	if(fh == nil)
		return;

	NSXMLDocument* xdoc = [[NSXMLDocument alloc] initWithData:[fh readDataToEndOfFile] options:0 error:NULL];
	
	if(xdoc == nil)
		return;
	
	for(NSString* tag in [tagReferences allKeys])
	{
		NSXMLElement* xelem = [[[xdoc rootElement] elementsForName:tag] count] > 0 ? [[[xdoc rootElement] elementsForName:tag] objectAtIndex:0] : nil;
		if(xelem == nil)
			continue;
		
		[*object setValue:[xelem stringValue] forKey:[tagReferences objectForKey:tag]];
	}
	
	for(NSString* tag in [attributeReferences allKeys])
	{
		NSXMLElement* xelem = [[[xdoc rootElement] elementsForName:tag] count] > 0 ? [[[xdoc rootElement] elementsForName:tag] objectAtIndex:0] : nil;
		if(xelem == nil)
			continue;
		
		for(NSString* attribute in [[attributeReferences objectForKey:tag] allKeys]) {
			NSXMLNode* attrNode = [xelem attributeForName:attribute];
			if(attrNode == nil)
				continue;
			[*object setValue:[attrNode stringValue] forKey:[[attributeReferences objectForKey:tag] objectForKey:attribute]];
		}
	}
	
	if(loadStats)
	{
		[*object setValue:[KMStat loadFromTemplateUsingXmlDocument:xdoc withType:statLoadType]];
	}
}

@synthesize loadStats;
@synthesize statKey;
@synthesize statLoadType;

@end
