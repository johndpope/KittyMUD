//
//  XDFVariableReference.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/25/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XDFReference.h"

@interface XDFVariableReference : XDFReference {
	NSString* variableName;
}

@property (retain) NSString* variableName;

@end

@interface XDFVariableReference ()

-(id) initializeWithVariableName:(NSString*)name;

@end