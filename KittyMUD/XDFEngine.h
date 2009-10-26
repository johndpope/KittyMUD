//
//  XDFEngine.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/24/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XDFReference.h"
#import "XDFFunctionInfo.h"

@interface XDFEngine : NSObject {
}

+(void)initialize;

+(void) registerFunctionWithName:(NSString*)name withSelector:(SEL)sel andTarget:(id)target;

+(XDFFunctionInfo*)getFunctionForName:(NSString*)name;

@end
