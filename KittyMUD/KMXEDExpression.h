//
//  KMXEDExpression.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/24/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMXED.h"
#import "KMXEDReference.h"

@interface KMXEDExpression : NSObject {
	KMXEDOpType operationType;
	NSArray* groupExpressions;
	KMXEDReference* reference0;
	KMXEDReference* reference1;
}

-(void) debugPrintSelf:(int)tablevel;

@property (retain) NSArray* groupExpressions;
@property (retain) KMXEDReference* reference0;
@property (retain) KMXEDReference* reference1;
@property (assign) KMXEDOpType operationType;
@end
