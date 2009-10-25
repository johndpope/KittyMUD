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
	KMXDFReference* myRef;
}

+(KMXDFReference*)createReferenceFromSource:(NSString*)source;

-(NSNumber*)resolveReferenceWithObject:(id)object;
@end

@interface KMXDFReference ()

+(KMXDFReference*)createReferenceOfType:(KMXDFRefType)type,...;

-(void)debugPrintSelf:(int)tabLevel;

-(id) initializeWithRef:(KMXDFReference*)ref;

@end

NSString* createTabString(int tabs);