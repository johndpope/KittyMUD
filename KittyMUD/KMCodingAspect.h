//
//  KMCodingAspect.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/15/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>

@interface KMCodingAspect : NSObject <NSCoding>
+(BOOL) addMethod:(SEL)aSelector toClass:(Class)aClass error:(NSError **)error;

+(BOOL) addToClass:(Class)aClass error:(NSError **)error;
@end

