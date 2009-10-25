//
//  KMXDFNumberReference.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/25/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMXDFNumberReference.h"


@implementation KMXDFNumberReference

-(id) initializeWithNumber:(NSNumber*)number
{
	self = [super init];
	if(self) {
		myNum = number;
	}
	return self;
}

-(NSNumber*) resolveReferenceWithObject:(id)object
{
	return myNum;
}

-(void) debugPrintSelf:(int)tabLevel {
	NSLog(@"%@Number Reference: %f", createTabString(tabLevel),[myNum floatValue]);
}

@synthesize myNum;
@end
