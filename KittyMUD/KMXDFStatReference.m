//
//  KMXDFStatReference.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/25/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMXDFStatReference.h"
#import "KMCharacter.h"
#import "KMStat.h"

@implementation KMXDFStatReference

-(id) initializeWithName:(NSString*)name {
	self = [super init];
	if(self)
		statName = name;
	return self;
}

-(NSNumber*)resolveReferenceWithObject:(id)object {
	if(![object isKindOfClass:[KMCharacter class]])
		return [NSNumber numberWithFloat:0];
	KMStat* stat = [[object stats] findStatWithPath:statName];
	if(!stat)
		return [NSNumber numberWithFloat:0];
	return [NSNumber numberWithInt:[stat statvalue]];
}

-(void) debugPrintSelf:(int)tabLevel {
	NSLog(@"%@Stat Reference: %@", createTabString(tabLevel),statName);
}
@synthesize statName;
@end
