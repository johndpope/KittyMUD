//
//  KMXDFExpression.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/24/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMXDFExpression.h"


@implementation KMXDFExpression

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

NSString* createTabString(int tabs) {
	NSMutableString* string = [[NSMutableString alloc] init];
	for(int i = 0; i < tabs; i++)
		[string appendString:@"\t"];
	return string;
}
			
-(void) debugPrintSelf:(int)tablevel {
	NSLog(@"%@Op: %@", createTabString(tablevel), opToString(operationType));
	[reference0 debugPrintSelf:tablevel+1];
	if(operationType != KMXDFOpPercent) {
		[reference1 debugPrintSelf:tablevel+1];
	}
}

@synthesize reference0;
@synthesize reference1;
@synthesize operationType;

@end
