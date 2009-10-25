//
//  KMXEDReference.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/24/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
	KMXEDFuncRef,
	KMXEDVarRef,
	KMXEDStatRef,
	KMXEDNumberRef,
	KMXEDExpressionRef,
} KMXEDRefType;

@interface KMXEDReference : NSObject {
	KMXEDRefType type;
	NSString* reference;
	id expression;
	float number;
}

-(void) debugPrintSelf:(int)tabLevel;

@property (retain) NSString* reference;
@property (assign) KMXEDRefType type;
@property (retain) id expression;
@property (assign) float number;
@end
