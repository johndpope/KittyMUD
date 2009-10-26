//
//  XDFExpressionReference.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/25/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XDFReference.h"

typedef enum {
	XDFOpAdd,
	XDFOpSubtract,
	XDFOpMultiply,
	XDFOpDivide,
	XDFOpModulus,
	XDFOpPercent
} XDFOpType;

@interface XDFExpressionReference : XDFReference {
	XDFOpType operationType;
	XDFReference* reference0;
	XDFReference* reference1;
}

@property (retain) XDFReference* reference0;
@property (retain) XDFReference* reference1;
@property (assign) XDFOpType operationType;
@end

@interface XDFExpressionReference ()

-(id) initializeWithOperationType:(XDFOpType)type andReference0:(XDFReference*)ref0 andReference1:(XDFReference*)ref1;

@end