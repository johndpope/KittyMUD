//
//  KMDataManager.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/3/09.
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

#import "KMDataManager.h"

@interface  KMDataManagerCustomLoading  : KMObject {
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
		[*object setValue:loadedObject forKey:[cl key]];
	}
}

@synthesize tagReferences;
@synthesize subtagReferences;
@synthesize attributeReferences;
@synthesize customLoaders;

@end
