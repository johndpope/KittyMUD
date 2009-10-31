//
//  KMInfoManager.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/11/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMObject.h"

@interface  KMInfoDisplay  : KMObject {
	NSMutableString* display;
}

-(id) init;

-(void) appendSeperator;

-(void) appendLine:(NSString*)line;

-(void) appendString:(NSString*)string;

-(NSString*) finalOutput;

@property (retain) NSMutableString* display;
@end
