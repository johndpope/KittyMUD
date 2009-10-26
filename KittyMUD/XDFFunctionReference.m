//
//  XDFFunctionReference.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/25/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "XDFFunctionReference.h"
#import "XDFFunctionInfo.h"
#import "XDFEngine.h"

@implementation XDFFunctionReference

-(id) initializeWithFunctionName:(NSString*)name andExpression:(XDFReference*)expr
{
	self = [super init];
	if(self) {
		funcName = name;
		expression = expr;
	}
	return self;
}

-(NSNumber*) resolveReferenceWithObject:(id)object {
	XDFFunctionInfo* funcInfo = [XDFEngine getFunctionForName:funcName];
	if(!funcInfo)
		return [NSNumber numberWithInt:0];
	NSMethodSignature* sig = [[[funcInfo target] class] instanceMethodSignatureForSelector:NSSelectorFromString([funcInfo selector])];
	NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
	[invocation setTarget:[funcInfo target]];
	[invocation setSelector:NSSelectorFromString([funcInfo selector])];
	NSNumber* res = [expression resolveReferenceWithObject:object];
	NSNumber* ret;
	[invocation setArgument:&res atIndex:2];
	[invocation invoke];
	[invocation getReturnValue:&ret];
	return ret;
}

-(void) debugPrintSelf:(int)tabLevel {
	NSLog(@"%@Function Reference: %@", createTabString(tabLevel), funcName);
	[expression debugPrintSelf:tabLevel+1];
}

@synthesize funcName;
@synthesize expression;
@end
