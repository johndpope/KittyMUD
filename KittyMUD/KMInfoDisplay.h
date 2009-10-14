//
//  KMInfoManager.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/11/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface KMInfoDisplay : NSObject {
	NSMutableString* display;
}

-(id) init;

-(void) appendSeperator;

-(void) appendLine:(NSString*)line;

-(void) appendString:(NSString*)string;

-(NSString*) finalOutput;

@end
