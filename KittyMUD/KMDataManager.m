//
//  KMDataManager.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/3/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMDataManager.h"

@interface KMDataManagerCustomLoading : NSObject {
	id<KMDataCustomLoader> loader;
	void* context;
	NSString* key;
}

@property (retain) id<KMDataCustomLoader> loader;
@property (assign) void* context;
@property (retain) NSString* key;
@end

@implementation KMDataManagerCustomLoading
@synthesize loader;
@synthesize context;
@synthesize key;
@end

@implementation KMDataManager

-(id)init
{
	self = [super init];
	if(self) {
		tagReferences = [[NSMutableDictionary alloc] init];
		attributeReferences = [[NSMutableDictionary alloc] init];
		customLoaders = [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(void)registerTag:(NSString*)tag forKey:(NSString*)key
{
	[tagReferences setObject:key forKey:tag];
}

-(void) registerTag:(NSString*)tag forKey:(NSString*)key forCustomLoading:(id<KMDataCustomLoader>)loader withContext:(void*)context {
	KMDataManagerCustomLoading* cl = [[KMDataManagerCustomLoading alloc] init];
	[cl setLoader:loader];
	[cl setContext:context];
	[cl setKey:key];
	[customLoaders setObject:cl forKey:tag];
}

-(void)registerTag:(NSString*)tag,...
{
	va_list args;
	va_start(args,tag);
	NSMutableDictionary* attributes = [[NSMutableDictionary alloc] init];
	id attribute,key;
	while(attribute = va_arg(args,id))
	{
		key = va_arg(args,id);
		[attributes setObject:key forKey:attribute];
	}
	va_end(args);
	[attributeReferences setObject:attributes forKey:tag];
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
		NSXMLElement* xelem = [[[xdoc rootElement] nodesForXPath:tag error:NULL] count] > 0 ? [[[xdoc rootElement] nodesForXPath:tag error:NULL] objectAtIndex:0] : nil;
		if(xelem == nil)
			continue;
		
		[*object setValue:[xelem stringValue] forKey:[tagReferences objectForKey:tag]];
	}
	
	for(NSString* tag in [attributeReferences allKeys])
	{
		NSXMLElement* xelem = [[[xdoc rootElement] nodesForXPath:tag error:NULL] count] > 0 ? [[[xdoc rootElement] nodesForXPath:tag error:NULL] objectAtIndex:0] : nil;
		if([[[xdoc rootElement] name] isEqualToString:tag])
			xelem = [xdoc rootElement];
		
		if(xelem == nil)
			continue;
		
		for(NSString* attribute in [[attributeReferences objectForKey:tag] allKeys]) {
			NSXMLNode* attrNode = [xelem attributeForName:attribute];
			if(attrNode == nil)
				continue;
			[*object setValue:[attrNode stringValue] forKey:[[attributeReferences objectForKey:tag] objectForKey:attribute]];
		}
	}
	
	for(NSString* tag in [customLoaders allKeys])
	{
		NSXMLElement* xelem = [[[xdoc rootElement] nodesForXPath:tag error:NULL] count] > 0 ? [[[xdoc rootElement] nodesForXPath:tag error:NULL] objectAtIndex:0] : nil;
		if([[[xdoc rootElement] name] isEqualToString:tag])
			xelem = [xdoc rootElement];
		
		if(xelem == nil)
			continue;

		KMDataManagerCustomLoading* cl = [customLoaders objectForKey:tag];
		id loadedObject = [[cl loader] customLoader:xelem withContext:[cl context]];
		[loadedObject debugPrintTree:0];
		[*object setValue:loadedObject forKey:[cl key]];
	}
}
@end
