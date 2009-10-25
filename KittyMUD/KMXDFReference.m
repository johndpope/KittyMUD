//
//  KMXDFReference.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/24/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMXDFReference.h"
#import "KMXDFStatReference.h"
#import "KMXDFFunctionReference.h"
#import "KMXDFExpressionReference.h"
#import "KMXDFVariableReference.h"
#import "KMXDFNumberReference.h"
#import "KMXDF.yy.h"

NSString* createTabString(int tabs) {
	NSMutableString* string = [[NSMutableString alloc] init];
	for(int i = 0; i < tabs; i++)
		[string appendString:@"\t"];
	return string;
}

@implementation KMXDFReference

+(KMXDFReference*)createReferenceFromSource:(NSString *)source {
	YY_BUFFER_STATE buff = XDF_scan_string([source cStringUsingEncoding:NSUTF8StringEncoding]);
	KMXDFReference* ref;
	XDFparse(&ref);
	XDF_delete_buffer(buff);
	return ref;
}

+(KMXDFReference*)createReferenceOfType:(KMXDFRefType)type,... {
	KMXDFReference* ref = [KMXDFReference alloc];
	KMXDFReference* myRef;
	va_list args;
	va_start(args,type);
	id obj,ref0,ref1, expr;
	KMXDFOpType opType;
	if(type != KMXDFExpressionRef)
		obj = va_arg(args,id);
	switch(type) {
		case KMXDFStatRef:
			myRef = [[KMXDFStatReference alloc] initializeWithName:obj];
			break;
		case KMXDFVarRef:
			myRef = [[KMXDFVariableReference alloc] initializeWithVariableName:obj];
			break;
		case KMXDFNumberRef:
			myRef = [[KMXDFNumberReference alloc]  initializeWithNumber:obj];
			break;
		case KMXDFExpressionRef:
			opType = va_arg(args,KMXDFOpType);
			ref0 = va_arg(args,id);
			ref1 = nil;
			if(opType != KMXDFOpPercent)
				ref1 = va_arg(args,id);
			myRef = [[KMXDFExpressionReference alloc] initializeWithOperationType:opType andReference0:ref0 andReference1:ref1];
			break;
		case KMXDFFuncRef:
			expr = va_arg(args,id);
			myRef = [[KMXDFFunctionReference alloc] initializeWithFunctionName:obj andExpression:expr];
			break;
	}
	va_end(args);
	ref = [ref initializeWithRef:myRef];
	return ref;
}

-(id) initializeWithRef:(KMXDFReference*)ref
{
	self = [super init];
	if(self) {
		myRef = ref;
	}
	return self;
}

-(NSNumber*) resolveReferenceWithObject:(id)object {
	NSLog(@"Resolving reference of type:%@", [myRef className]);
	return [myRef resolveReferenceWithObject:object];
}

-(void) debugPrintSelf:(int)tabLevel {
	[myRef debugPrintSelf:tabLevel];
}

@end
