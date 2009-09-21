//
//  KMCharacter.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMStat.h"

@interface KMCharacter : NSObject {
	NSMutableDictionary* properties;
	KMStat* stats;
}

-(NSMutableDictionary*) getProperties;

-(id)initializeWithName:(NSString*)name;

@property KMStat* stats;

@end
