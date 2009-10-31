//
//  KMAccountMenu.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/18/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMMenu.h"

@protocol KMAccountMenu <NSObject,KMMenu>

+(NSArray*)requirements;

+(int) priority;

@end
