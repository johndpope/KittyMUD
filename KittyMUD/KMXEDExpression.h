//
//  KMXEDExpression.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/24/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMXEDReference.h"

typedef enum {
	KMXEDOpAdd,
	KMXEDOpSubtract,
	KMXEDOpMultiply,
	KMXEDOpDivide,
	KMXEDOpModulus,
	KMXEDOpPercent
} KMXEDOpType;

@interface KMXEDExpression : NSObject {
	KMXEDOpType operationType;
	KMXEDReference* reference0;
	KMXEDReference* reference1;
}

-(void) debugPrintSelf:(int)tablevel;

@property (retain) KMXEDReference* reference0;
@property (retain) KMXEDReference* reference1;
@property (assign) KMXEDOpType operationType;
@end
