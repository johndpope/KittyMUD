//
//  XDFFunctionReference.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/25/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XDFReference.h"

@interface XDFFunctionReference : XDFReference
{
	NSString* funcName;
	XDFReference* expression;
}

@property (retain) NSString* funcName;
@property (retain) XDFReference* expression;
@end

@interface XDFFunctionReference ()

-(id) initializeWithFunctionName:(NSString*)name andExpression:(XDFReference*)expression;

@end