//
//  KMXDFExpressionReference.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/25/09.
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

@interface KMXDFExpressionReference : KMXDFReference {
	KMXDFOpType operationType;
	KMXDFReference* reference0;
	KMXDFReference* reference1;
}

@property (retain) KMXDFReference* reference0;
@property (retain) KMXDFReference* reference1;
@property (assign) KMXDFOpType operationType;
@end

@interface KMXDFExpressionReference ()

-(id) initializeWithOperationType:(KMXDFOpType)type andReference0:(KMXDFReference*)ref0 andReference1:(KMXDFReference*)ref1;

@end