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
	KMStat* stats;
}

-(id)initializeWithName:(NSString*)name;

-(NSXMLElement*) saveToXML;

+(KMCharacter*) loadFromXML:(NSXMLElement*)xelem;

@property (retain) KMStat* stats;
@end
