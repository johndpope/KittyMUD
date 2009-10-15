//
//  KMCommandInfo.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/15/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMCommandInfo.h"


@implementation KMCommandInfo

-(id) init {
	self = [super init];
	if(self) {
		optArgs = [[NSArray alloc] init];
		aliases = [[NSArray alloc] init];
		flags = [[NSArray alloc] init];
		help = [[NSDictionary alloc] init];
	}
	return self;
}

@synthesize method;
@synthesize name;
@synthesize optArgs;
@synthesize aliases;
@synthesize flags;
@synthesize help;
@synthesize minLevel;
@synthesize target;
@synthesize coordinator;
@end
