//
//  KMAchievementEngine.m
//  KittyMUD
//
//  Created by Michael Tindal on 11/17/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as 
// published by the Free Software Foundation; either version 3 of 
// the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
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
			ECSNode* c = [a earnCriteria];
            NSMutableDictionary* context = [NSMutableDictionary dictionary];
            [context createSymbolTable];
            ECSSymbol* co = [[context symbolTable] symbolWithName:@"coordinator"];
            co.value = coordinator;
			BOOL earn =  [[c evaluateWithContext:context] boolValue];
			if(earn) {
				[a displayAchievementHasBeenEarnedMessageTo:coordinator];
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
