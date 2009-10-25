//
//  KMXDFEngine.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/24/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMXDFEngine.h"
#import "KMXDFReference.h"

static NSMutableDictionary* functions;

@implementation KMXDFEngine

+(void)initialize {
	functions = [[NSMutableDictionary alloc] init];
}

+(void) registerFunctionWithName:(NSString*)name withSelector:(SEL)sel andTarget:(id)target
{
	KMXDFFunctionInfo* func = [[KMXDFFunctionInfo alloc] init];
	[func setName:name];
	[func setSelector:NSStringFromSelector(sel)];
	[func setTarget:target];
	[functions setObject:func forKey:name];
}

+(KMXDFFunctionInfo*)getFunctionForName:(NSString*)name
{
	KMXDFFunctionInfo* func = [functions objectForKey:name];
	return func;
}

@end
