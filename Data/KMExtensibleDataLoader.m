//
//  XDFLoader.m
//  XDF
//
//  Created by Michael Tindal on 10/31/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//

#import "KMExtensibleDataLoader.h"

NSString* currentFileName;

@implementation KMExtensibleDataLoader

+(NSString*) currentFileName {
	return currentFileName;
}

-(NSArray*) loadFile:(NSString*)path withSchema:(id<KMExtensibleDataSchema>)schema {
	Class type = [schema schemaType];
	NSMutableArray* objects = [[NSMutableArray alloc] init];
	NSFileHandle* fh = [NSFileHandle fileHandleForReadingAtPath:path];
	if(!fh)
		return nil;
	currentFileName = [path lastPathComponent];
	NSData* data = [fh readDataToEndOfFile];
	NSXMLDocument* doc = [[NSXMLDocument alloc] initWithData:data options:NSXMLDocumentXInclude error:NULL];
	if(!doc)
		return nil;
	NSXMLElement* root = [doc rootElement];
	if(![[root name] isEqualTo:@"data"]) {
		OCLog(@"xdf",warning,@"Invalid XDF data file.");
		return nil;
	}
	NSXMLNode* node = [root attributeForName:@"type"];
	NSString* dtype = [node stringValue];
	if(![dtype isEqualTo:[schema dataType]]) {
		OCLog(@"xdf",warning,@"Given XDF file does match given schema.");
		return nil;
	}
	NSArray* childNodes = [root children];
	for(NSXMLElement* element in childNodes) {
		NSArray* echildNodes = [element children];
		id object = [[type alloc] init];
		for(NSXMLNode* attribute in [element attributes]) {
			NSString* akey = [schema keyForAttribute:[attribute name] onTag:[element name]];
			if(!akey)
				continue;
			NSInvocation* ainv = [schema invocationToLoadKey:akey];
			if(akey) {
				if(ainv) {
					[ainv setArgument:&attribute atIndex:2];
					[ainv invoke];
					id arval;
					[ainv getReturnValue:&arval];
					if(arval) {
						if([akey isEqualToString:@"self"]) {
							object = arval;
						} else {
							[object setValue:arval forKeyPath:akey];
						}
					}
				} else {
					if([akey isEqualToString:@"self"]) {
						object = [attribute stringValue];
					} else {
						[object setValue:[attribute stringValue] forKeyPath:akey];
					}
				}
			}
		}
		for(NSXMLElement* echild in echildNodes) {
			NSString* key = [schema keyForTag:[echild name]];
			if(!key)
				continue;
			NSInvocation* inv = [schema invocationToLoadKey:key];
			if(key) {
				if(inv) {
					[inv setArgument:&echild atIndex:2];
					[inv invoke];
					id rval;
					[inv getReturnValue:&rval];
					if([key isEqualToString:@"self"]) {
						object = rval;
					} else {
						[object setValue:rval forKeyPath:key];
					}
				} else {
					if([key isEqualToString:@"self"]) {
						object = [echild stringValue];
					} else {
						[object setValue:[echild stringValue] forKeyPath:key];
					}
				}
			}
			for(NSXMLNode* attribute in [echild attributes]) {
				NSString* akey = [schema keyForAttribute:[attribute name] onTag:[echild name]];
				if(!akey)
					continue;
				NSInvocation* ainv = [schema invocationToLoadKey:akey];
				if(akey) {
					if(ainv) {
						[ainv setArgument:&attribute atIndex:2];
						[ainv invoke];
						id arval;
						[ainv getReturnValue:&arval];
						if([akey isEqualToString:@"self"]) {
							object = arval;
						} else {
							[object setValue:arval forKeyPath:akey];
						}
					} else {
						if([akey isEqualToString:@"self"]) {
							object = [attribute stringValue];
						} else {
							[object setValue:[attribute stringValue] forKeyPath:akey];
						}
					}
				}
			}
		}
		[objects addObject:object];
	}
	return objects;
}
@end
