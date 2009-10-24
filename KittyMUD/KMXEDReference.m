//
//  KMXEDReference.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/24/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMXEDReference.h"


@implementation KMXEDReference

NSString* rcreateTabString(int tabs) {
	NSMutableString* string = [[NSMutableString alloc] init];
	for(int i = 0; i < tabs; i++)
		[string appendString:@"\t"];
	return string;
}

-(void) debugPrintSelf:(int)tabLevel {
	if(isGrouped)
		NSLog(@"%@Following reference is grouped:", rcreateTabString(tabLevel));
	switch(type) {
		case KMXEDFuncRef:
			NSLog(@"%@Function Reference: %@", rcreateTabString(tabLevel), reference);
			[expression debugPrintSelf:tabLevel+1];
			break;
		case KMXEDVarRef:
			NSLog(@"%@Variable Reference: %@", rcreateTabString(tabLevel),reference);
			break;
		case KMXEDStatRef:
			NSLog(@"%@Stat Reference: %@", rcreateTabString(tabLevel),reference);
			break;
		case KMXEDNumberRef:
			NSLog(@"%@Number Reference: %f", rcreateTabString(tabLevel),number);
			break;
		case KMXEDExpressionRef:
			NSLog(@"%@Expression Reference:", rcreateTabString(tabLevel));
			[expression debugPrintSelf:tabLevel+1];
			break;
	}
}
@synthesize reference;
@synthesize type;
@synthesize expression;
@synthesize number;
@synthesize isGrouped;
@end
