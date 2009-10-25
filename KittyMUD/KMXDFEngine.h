//
//  KMXDFEngine.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/24/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMXDFReference.h"
#import "KMXDFFunctionInfo.h"

@interface KMXDFEngine : NSObject {
}

+(void)initialize;

+(void) registerFunctionWithName:(NSString*)name withSelector:(SEL)sel andTarget:(id)target;

+(KMXDFFunctionInfo*)getFunctionForName:(NSString*)name;

@end
