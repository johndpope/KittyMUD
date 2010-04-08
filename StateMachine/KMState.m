//
//  KMState.m
//  KittyMUD
//
//  Created by Michael Tindal on 4/5/10.
//  Copyright 2010 Michael Tindal. All rights reserved.
//

#import "KMState.h"

@implementation KMState

+(NSString*) getName {
	return NSStringFromClass(self);
}

-(id) initWithCoordinator:(KMConnectionCoordinator*)coord {
	self = [super init];
	if(self) {
		self.coordinator = coord;
	}
	return self;
}

@synthesize coordinator;

@end
