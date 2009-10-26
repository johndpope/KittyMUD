//
//  XDFStatReference.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/25/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "XDFStatReference.h"

@interface NSObject (XDFStatForward)

-(id)stats;

-(id)findStatWithPath:(NSString*)name;

-(int)statvalue;

@end

@implementation XDFStatReference

-(id) initializeWithName:(NSString*)name {
	self = [super init];
	if(self)
		statName = name;
	return self;
}

-(NSNumber*)resolveReferenceWithObject:(id)object {
	@try {
		id stat = [[object stats] findStatWithPath:statName];
		return [NSNumber numberWithInt:[stat statvalue]];
	} @catch (id exc) {
		return [NSNumber numberWithInt:0];
	}
	return [NSNumber numberWithInt:0];
}

-(void) debugPrintSelf:(int)tabLevel {
	NSLog(@"%@Stat Reference: %@", createTabString(tabLevel),statName);
}
@synthesize statName;
@end
