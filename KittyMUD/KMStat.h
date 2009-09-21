//
//  KMStat.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum
{
	KMStatLoadTypeDefault,
	KMStatLoadTypeRace,
	KMStatLoadTypeJob,
	KMStatLoadTypeAllocation,
	KMStatLoadTypeSave,
} KMStatLoadType;


@interface KMStat : NSObject {
	int statvalue;
	NSString* name;
	NSString* abbreviation;
	KMStat* parent;
	NSMutableArray* children;
	NSMutableDictionary* properties;
}

-(id) init;

-(id) initializeWithValue:(int)val;

-(id) initializeWithName:(NSString*)sname andValue:(int)val;

-(void) addChild:(KMStat*)child;

-(BOOL) hasChildren;

-(void) setValueOfChildAtPath:(NSString*)path withValue:(int)val;

-(int) getValueOfChildAtPath:(NSString*)path;

-(KMStat*) findStatWithPath:(NSString*)path;

+(KMStat*) loadFromTemplateAtPath:(NSString*)path;

+(KMStat*) loadFromTemplateAtPath:(NSString*)path withType:(KMStatLoadType)loadType;

+(KMStat*) loadFromTemplateUsingXmlDocument:(NSXMLDocument*)doc;

+(KMStat*) loadFromTemplateUsingXmlDocument:(NSXMLDocument*)doc withType:(KMStatLoadType)loadType;

+(KMStat*) loadFromTemplateWithData:(NSData*)data;

+(KMStat*) loadFromTemplateWithData:(NSData*)data withType:(KMStatLoadType)loadType;

@property (retain,getter=getChildren,setter=setChildren:) NSArray* children;
@property (assign) int statvalue;
@property (retain,getter=getProperties,setter=setProperties:) NSMutableDictionary* properties;
@property (copy) NSString* name;
@property (retain) KMStat* parent;
@end

@interface KMStat ()

-(void)debugPrintTree:(int)tabLevel;

@end 

@interface NSXMLElement (Private)

- (id)valueForUndefinedKey:(NSString *)key;

@end