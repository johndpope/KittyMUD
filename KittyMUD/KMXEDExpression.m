//
//  KMXEDExpression.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/24/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMXEDExpression.h"


@implementation KMXEDExpression

NSString* opToString(KMXEDOpType type) {
	switch(type) {
		case KMXEDOpAdd:
			return @"+";
		case KMXEDOpSubtract:
			return @"-";
		case KMXEDOpMultiply:
			return @"*";
		case KMXEDOpDivide:
			return @"/";
		case KMXEDOpModulus:
			return @"^";
		case KMXEDOpPercent:
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
	if(operationType != KMXEDOpPercent) {
		[reference1 debugPrintSelf:tablevel+1];
	}
}

@synthesize reference0;
@synthesize reference1;
@synthesize operationType;

@end
