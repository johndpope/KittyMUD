//
//  XDFVariableReference.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/25/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "XDFVariableReference.h"


@implementation XDFVariableReference

-(id) initializeWithVariableName:(NSString*)name
{
	self = [super init];
	if(self)
		variableName = name;
	return self;
}

-(NSNumber*) resolveReferenceWithObject:(id)object {
	return [NSNumber numberWithInt:0];
}

-(void)debugPrintSelf:(int)tabLevel {
	NSLog(@"%@Variable Reference: %@", createTabString(tabLevel),variableName);
}

@synthesize variableName;
@end
