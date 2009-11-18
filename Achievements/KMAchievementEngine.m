//
//  KMAchievementEngine.m
//  KittyMUD
//
//  Created by Michael Tindal on 11/17/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//

#import "KMAchievementEngine.h"

@implementation KMAchievementEngine

-(id) init {
	self = [super init];
	if(self) {
		achievements = [NSMutableDictionary dictionary];
	}
	return self;
}

-(void) addAchievement:(KMAchievement*)a toCategory:(NSString*)category {
	if(![achievements objectForKey:category])
		[achievements setObject:[NSMutableArray array] forKey:category];
	NSMutableArray* ar = [achievements objectForKey:category];
	if(![ar containsObject:a])
		[ar addObject:a];
}

-(void) checkForNewAchievements:(id)coordinator {
	for(NSString* category in [achievements allKeys]) {
		for(KMAchievement* a in [achievements objectForKey:category]) {
			XSHNode* c = [a earnCriteria];
			[c resolveNodeWithObject:coordinator];
			while(![c returned]);
			BOOL earn = [[c returnValue] boolValue];
			if(earn) {
				[a displayAchievementEarnedMessage:coordinator];
				/// TODO:  Add achievement point stuff here
			}
		}
	}
}

-(NSArray*) achievementsForCategory:(NSString*)category {
	if([achievements objectForKey:category]) {
		return (NSArray*)[achievements objectForKey:category];
	}
	return nil;
}

-(NSArray*) achievementCategories {
	return [achievements allKeys];
}

@end
