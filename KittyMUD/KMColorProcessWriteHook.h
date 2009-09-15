//
//  KMColorProcessWriteHook.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface KMColorProcessWriteHook : NSObject {
	NSDictionary* colors;
}

-(id) init;

-(NSString*) processHook:(NSString*)input;
@end
