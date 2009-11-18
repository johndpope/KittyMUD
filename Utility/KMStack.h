//
//  KMStack.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/11/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMObject.h"

@interface  KMStack  : KMObject {
	NSMutableArray* items;
}

-(id) init;

-(id) pop;

-(void) push:(id)obj;

-(id) peek;

@property (retain) NSMutableArray* items;
@end