//
//  KMAccountMenu.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol KMAccountMenu <NSObject>

+(NSArray*)requirements;

+(NSString*)menuLine;

+(int) priority;

@end
