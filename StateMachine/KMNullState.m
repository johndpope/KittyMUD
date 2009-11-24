//
//  KMNullState.m
//  KittyMUD
//
//  Created by Michael Tindal on 11/23/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//


#import "KMState.h"

@implementation KMNullState

+(void) processState:(id)coordinator { }

+(NSString*) getName { return @"Null"; }

+(void) softRebootMessage:(id)coordinator { }
@end

