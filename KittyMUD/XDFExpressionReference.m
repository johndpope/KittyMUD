//
//  XDFExpressionReference.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/25/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "XDFExpressionReference.h"

NSString* opToString(XDFOpType type) {
	switch(type) {
		case XDFOpAdd:
			return @"+";
		case XDFOpSubtract:
			return @"-";
		case XDFOpMultiply:
			return @"*";
		case XDFOpDivide:
			return @"/";
		case XDFOpModulus:
			return @"^";
		case XDFOpPercent:
			return @"%";
	}
}

@implementation XDFExpressionReference

-(id) initializeWithOperationType:(XDFOpType)type andReference0:(XDFReference*)ref0 andReference1:(XDFReference*)ref1 {
	self = [super init];
	if(self) {
		operationType = type;
		reference0 = ref0;
		if(operationType == XDFOpPercent) {
			operationType = XDFOpDivide;
			reference1 = [XDFReference createReferenceOfType:XDFNumberRef,[NSNumber numberWithInt:100]];
		} else {
			reference1 = ref1;
		}
	}
	return self;
}

-(NSNumber*) resolveReferenceWithObject:(id)object
{
	NSNumber* ref0 = [reference0 resolveReferenceWithObject:object];
	NSNumber* ref1 = [reference1 resolveReferenceWithObject:object];
	float f0 = [ref0 floatValue];
	float f1 = [ref1 floatValue];
	float f2;
	switch(operationType) {
		case XDFOpAdd:
			f2 = f0 + f1;
			break;
		case XDFOpSubtract:
			f2 = f0 - f1;
			break;
		case XDFOpDivide:
			f2 = f0 / f1;
			break;
		case XDFOpMultiply:
			f2 = f0 * f1;
			break;
		case XDFOpModulus:
			f2 = (float)((int)f0 % (int)f1);
			break;
	}
	return [NSNumber numberWithFloat:f2];
}

-(void) debugPrintSelf:(int)tabLevel {
	NSLog(@"%@Expression Reference:", createTabString(tabLevel));
	NSLog(@"%@Op: %@", createTabString(tabLevel++), opToString(operationType));
	[reference0 debugPrintSelf:tabLevel++];
	if(operationType != XDFOpPercent) {
		[reference1 debugPrintSelf:tabLevel];
	}
}

@synthesize reference0;
@synthesize reference1;
@synthesize operationType;
@end
