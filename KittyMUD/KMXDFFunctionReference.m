//
//  KMXDFFunctionReference.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/25/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMXDFFunctionReference.h"
#import "KMXDFFunctionInfo.h"
#import "KMXDFEngine.h"

@implementation KMXDFFunctionReference

-(id) initializeWithFunctionName:(NSString*)name andExpression:(KMXDFReference*)expr
{
	self = [super init];
	if(self) {
		funcName = name;
		expression = expr;
	}
	return self;
}

-(NSNumber*) resolveReferenceWithObject:(id)object {
	KMXDFFunctionInfo* funcInfo = [KMXDFEngine getFunctionForName:funcName];
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
