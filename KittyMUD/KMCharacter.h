//
//  KMCharacter.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMStat.h"
#import "KMMenu.h"

@interface KMCharacter : NSObject <KMMenu> {
	NSMutableDictionary* properties;
	KMStat* stats;
	NSMutableArray* flagbase;
	NSMutableDictionary* flags;
	unsigned int currentbitpower;
}

-(NSMutableDictionary*) getProperties;

-(id)initializeWithName:(NSString*)name;

-(NSXMLElement*) saveToXML;

+(KMCharacter*) loadFromXML:(NSXMLElement*)xelem;

-(BOOL) isFlagSet:(NSString*)flagName;

-(void) setFlag:(NSString*)flagName;

-(void) clearFlag:(NSString*)flagName;

@property KMStat* stats;

@property (retain,readonly,getter=getProperties) NSMutableDictionary* properties;
@end
