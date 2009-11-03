//
//  KMCharacter.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/19/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMStat.h"
#import "KMMenu.h"
#import "KMObject.h"

@interface  KMCharacter  : KMObject <KMMenu> {
	NSMutableDictionary* properties;
	KMStat* stats;
	NSMutableArray* flagbase;
	NSMutableDictionary* flags;
	unsigned int currentbitpower;
}

+(void) setDefaultStats:(KMStat*)def;

+(KMStat*) defaultStats;

-(NSMutableDictionary*) getProperties;

-(id)initializeWithName:(NSString*)name;

-(NSXMLElement*) saveToXML;

+(KMCharacter*) loadFromXML:(NSXMLElement*)xelem;

-(BOOL) isFlagSet:(NSString*)flagName;

-(void) setFlag:(NSString*)flagName;

-(void) clearFlag:(NSString*)flagName;

-(void) debugPrintFlagStatus:(id)coordinator;

@property KMStat* stats;

@property (retain,readonly,getter=getProperties) NSMutableDictionary* properties;
@property (retain) NSMutableArray* flagbase;
@property (retain) NSMutableDictionary* flags;
@property unsigned int currentbitpower;
@end
