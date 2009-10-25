//
//  KMXDFFunctionReference.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/25/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMXDFReference.h"

@interface KMXDFFunctionReference : KMXDFReference
{
	NSString* funcName;
	KMXDFReference* expression;
}

@property (retain) NSString* funcName;
@property (retain) KMXDFReference* expression;
@end

