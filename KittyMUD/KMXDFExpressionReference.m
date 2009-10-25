//
//  KMXDFExpressionReference.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/25/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMXDFExpressionReference.h"

NSString* opToString(KMXDFOpType type) {
	switch(type) {
		case KMXDFOpAdd:
			return @"+";
		case KMXDFOpSubtract:
			return @"-";
		case KMXDFOpMultiply:
			return @"*";
		case KMXDFOpDivide:
			return @"/";
		case KMXDFOpModulus:
			return @"^";
		case KMXDFOpPercent:
			return @"%";
	}
}

@implementation KMXDFExpressionReference

-(id) initializeWithOperationType:(KMXDFOpType)type andReference0:(KMXDFReference*)ref0 andReference1:(KMXDFReference*)ref1 {
	self = [super init];
	if(self) {
		operationType = type;
		reference0 = ref0;
		if(operationType == KMXDFOpPercent) {
			operationType = KMXDFOpDivide;
			reference1 = [KMXDFReference createReferenceOfType:KMXDFNumberRef,[NSNumber numberWithInt:100]];
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
		case KMXDFOpAdd:
			f2 = f0 + f1;
			break;
		case KMXDFOpSubtract:
			f2 = f0 - f1;
			break;
		case KMXDFOpDivide:
			f2 = f0 / f1;
			break;
		case KMXDFOpMultiply:
			f2 = f0 * f1;
			break;
		case KMXDFOpModulus:
			f2 = (float)((int)f0 % (int)f1);
			break;
	}
	return [NSNumber numberWithFloat:f2];
}

-(void) debugPrintSelf:(int)tabLevel {
	NSLog(@"%@Expression Reference:", createTabString(tabLevel));
	NSLog(@"%@Op: %@", createTabString(tabLevel++), opToString(operationType));
	[reference0 debugPrintSelf:tabLevel++];
	if(operationType != KMXDFOpPercent) {
		[reference1 debugPrintSelf:tabLevel];
	}
}

@synthesize reference0;
@synthesize reference1;
@synthesize operationType;
@end
