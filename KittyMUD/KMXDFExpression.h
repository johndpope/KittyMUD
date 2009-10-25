//
//  KMXDFExpression.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/24/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMXDFReference.h"

typedef enum {
	KMXDFOpAdd,
	KMXDFOpSubtract,
	KMXDFOpMultiply,
	KMXDFOpDivide,
	KMXDFOpModulus,
	KMXDFOpPercent
} KMXDFOpType;

@interface KMXDFExpression : NSObject {
	KMXDFOpType operationType;
	KMXDFReference* reference0;
	KMXDFReference* reference1;
}

-(void) debugPrintSelf:(int)tablevel;

@property (retain) KMXDFReference* reference0;
@property (retain) KMXDFReference* reference1;
@property (assign) KMXDFOpType operationType;
@end
