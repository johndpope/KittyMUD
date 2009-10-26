//
//  XDFReference.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/24/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
	XDFFuncRef,
	XDFVarRef,
	XDFStatRef,
	XDFNumberRef,
	XDFExpressionRef,
} XDFRefType;

@interface XDFReference : NSObject {
	XDFReference* myRef;
}

+(XDFReference*)createReferenceFromSource:(NSString*)source;

-(NSNumber*)resolveReferenceWithObject:(id)object;
@end

@interface XDFReference ()

+(XDFReference*)createReferenceOfType:(XDFRefType)type,...;

-(void)debugPrintSelf:(int)tabLevel;

-(id) initializeWithRef:(XDFReference*)ref;

@end

NSString* createTabString(int tabs);