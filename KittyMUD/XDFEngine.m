//
//  XDFEngine.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/24/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "XDFEngine.h"
#import "XDFReference.h"

static NSMutableDictionary* functions;

@implementation XDFEngine

+(void)initialize {
	functions = [[NSMutableDictionary alloc] init];
}

+(void) registerFunctionWithName:(NSString*)name withSelector:(SEL)sel andTarget:(id)target
{
	XDFFunctionInfo* func = [[XDFFunctionInfo alloc] init];
	[func setName:name];
	[func setSelector:NSStringFromSelector(sel)];
	[func setTarget:target];
	[functions setObject:func forKey:name];
}

+(XDFFunctionInfo*)getFunctionForName:(NSString*)name
{
	XDFFunctionInfo* func = [functions objectForKey:name];
	return func;
}

@end
