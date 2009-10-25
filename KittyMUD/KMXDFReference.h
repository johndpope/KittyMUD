//
//  KMXDFReference.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/24/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
	KMXDFFuncRef,
	KMXDFVarRef,
	KMXDFStatRef,
	KMXDFNumberRef,
	KMXDFExpressionRef,
} KMXDFRefType;

@interface KMXDFReference : NSObject {
	KMXDFRefType type;
	NSString* reference;
	id expression;
	float number;
}

-(void) debugPrintSelf:(int)tabLevel;

@property (retain) NSString* reference;
@property (assign) KMXDFRefType type;
@property (retain) id expression;
@property (assign) float number;
@end
