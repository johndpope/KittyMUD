//
//  KMWriteHook.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol KMWriteHook

-(NSString*) processHook:(NSString*) input;

@end
