//
//  KMStat.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/20/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMDataStartup.h"
#import "KMObject.h"
#import "KMStatCopy.h"

typedef enum
{
	KMStatLoadTypeDefault,
	KMStatLoadTypeRace,
	KMStatLoadTypeJob,
	KMStatLoadTypeAllocation,
	KMStatLoadTypeSave,
} KMStatLoadType;


@interface  KMStat  : KMObject <KMDataCustomLoader> {
	int statvalue;
	NSString* name;
	NSString* abbreviation;
	KMStat* parent;
	NSMutableArray* children;
	NSMutableDictionary* properties;
}

-(id) init;

-(id) initializeWithName:(NSString*)sname andValue:(int)val;

-(id) initializeWithName:(NSString*)sname andAbbreviation:(NSString*)sabbr;

-(id) initializeWithName:(NSString*)sname andAbbreviation:(NSString*)sabbr andValue:(int)val;

-(void) addChild:(KMStat*)child;

-(BOOL) hasChildren;

-(void) setValueOfChildAtPath:(NSString*)path withValue:(int)val;

-(int) getValueOfChildAtPath:(NSString*)path;

-(KMStat*) findStatWithPath:(NSString*)path;

+(KMStat*) loadFromTemplateAtPath:(NSString*)path;

+(KMStat*) loadFromTemplateAtPath:(NSString*)path withType:(KMStatLoadType)loadType;

+(KMStat*) loadFromTemplateUsingXmlDocument:(NSXMLDocument*)doc;

+(KMStat*) loadFromTemplateUsingXmlDocument:(NSXMLDocument*)doc withType:(KMStatLoadType)loadType;

+(KMStat*) loadFromTemplateWithRootElement:(NSXMLElement*)root;

+(KMStat*) loadFromTemplateWithRootElement:(NSXMLElement*)root withType:(KMStatLoadType)loadType;

+(KMStat*) loadFromTemplateWithData:(NSData*)data;

+(KMStat*) loadFromTemplateWithData:(NSData*)data withType:(KMStatLoadType)loadType;

+(KMStat*) loadFromTemplateWithString:(NSString*)string;

+(KMStat*) loadFromTemplateWithString:(NSString*) string withType:(KMStatLoadType)loadType;

-(NSXMLElement*) saveToXML;

-(NSArray*) getChildren;

-(void) copyStat:(KMStat*)stat;

-(void) copyStat:(KMStat*)stat withSettings:(KMStatCopySettings)settings;

@property (retain,readonly,getter=getChildren) NSArray* children;
@property (assign) int statvalue;
@property (retain,readonly,getter=getProperties) NSMutableDictionary* properties;
@property (copy) NSString* name;
@property (retain) KMStat* parent;
@property (retain) NSString* abbreviation;
@end

@interface KMStat ()

-(void)debugPrintTree:(int)tabLevel;

@end 

@interface NSXMLElement (Private)

- (id)valueForUndefinedKey:(NSString *)key;

@end