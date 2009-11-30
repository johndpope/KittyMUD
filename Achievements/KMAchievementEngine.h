//
//  KMAchievementEngine.h
//  KittyMUD
//
//  Created by Michael Tindal on 11/17/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMAchievement.h"

@interface KMAchievementEngine : NSObject {
	NSMutableDictionary* achievements;
}

-(void) addAchievement:(KMAchievement*)a toCategory:(NSString*)category;

-(void) checkForNewAchievements:(id)coordinator;

-(NSArray*) achievementsForCategory:(NSString*)category;

-(NSArray*) achievementCategories;

@end
