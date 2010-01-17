//
//  KMAchievement.m
//  KittyMUD
//
//  Created by Michael Tindal on 11/17/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//

#import "KMAchievement.h"
#import "KMConnectionCoordinator.h"

@implementation KMAchievement

-(id) initWithName:(NSString *)n description:(NSString *)d points:(NSNumber *)p criteria:(ECSNode*)c{
	self = [super init];
	if(self) {
		name = n;
		description = d;
		pointValue = p;
		earnCriteria = c;
	}
	return self;
}

-(void) displayAchievementHasBeenEarnedMessageTo:(id)coordinator {
	[coordinator sendMessageToBuffer:@"`Y[`y\u2606`w%@`y\u2606 `w(`G%d`w)`Y] `Wearned!`x",name,[pointValue intValue]];
}

-(void) displayAchievementDetailMessageTo:(id)coordinator {
	[coordinator sendMessageToBuffer:@"`Y[`y\u2606`w%@`y\u2606 `w(`G%d`w)`Y]`x",name,[pointValue intValue]];
	[coordinator sendMessageToBuffer:description];
}

@synthesize name,description,pointValue,earnCriteria;

@end