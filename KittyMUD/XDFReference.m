//
//  XDFReference.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/24/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "XDFReference.h"
#import "XDFStatReference.h"
#import "XDFFunctionReference.h"
#import "XDFExpressionReference.h"
#import "XDFVariableReference.h"
#import "XDFNumberReference.h"
#import "XDF.yy.h"

NSString* createTabString(int tabs) {
	NSMutableString* string = [[NSMutableString alloc] init];
	for(int i = 0; i < tabs; i++)
		[string appendString:@"\t"];
	return string;
}

@implementation XDFReference

+(XDFReference*)createReferenceFromSource:(NSString *)source {
	YY_BUFFER_STATE buff = XDF_scan_string([source cStringUsingEncoding:NSUTF8StringEncoding]);
	XDFReference* ref;
	XDFparse(&ref);
	XDF_delete_buffer(buff);
	return ref;
}

+(XDFReference*)createReferenceOfType:(XDFRefType)type,... {
	XDFReference* ref = [XDFReference alloc];
	XDFReference* myRef;
	va_list args;
	va_start(args,type);
	id obj,ref0,ref1, expr;
	XDFOpType opType;
	if(type != XDFExpressionRef)
		obj = va_arg(args,id);
	switch(type) {
		case XDFStatRef:
			myRef = [[XDFStatReference alloc] initializeWithName:obj];
			break;
		case XDFVarRef:
			myRef = [[XDFVariableReference alloc] initializeWithVariableName:obj];
			break;
		case XDFNumberRef:
			myRef = [[XDFNumberReference alloc]  initializeWithNumber:obj];
			break;
		case XDFExpressionRef:
			opType = va_arg(args,XDFOpType);
			ref0 = va_arg(args,id);
			ref1 = nil;
			if(opType != XDFOpPercent)
				ref1 = va_arg(args,id);
			myRef = [[XDFExpressionReference alloc] initializeWithOperationType:opType andReference0:ref0 andReference1:ref1];
			break;
		case XDFFuncRef:
			expr = va_arg(args,id);
			myRef = [[XDFFunctionReference alloc] initializeWithFunctionName:obj andExpression:expr];
			break;
	}
	va_end(args);
	ref = [ref initializeWithRef:myRef];
	return ref;
}

-(id) initializeWithRef:(XDFReference*)ref
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
