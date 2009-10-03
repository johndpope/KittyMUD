//
//  KMCharacter.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "KMCharacter.h"
#import "KittyMudStringExtensions.h"

@implementation KMCharacter

-(id)initializeWithName:(NSString *)name
{
	self = [super init];
	if(self) {
		properties = [[NSMutableDictionary alloc] init];
		[properties setObject:name forKey:@"name"];
		stats = [KMStat loadFromTemplateAtPath:[@"$(DataDir)/templates/stat_template.xml" replaceAllVariables]];
		[stats debugPrintTree:0];
	}
	return self;
}

@synthesize stats;
@synthesize properties;
@end
