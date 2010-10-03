//
//  KMAchievement.m
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

#import "KMAchievement.h"
#import "KMConnectionCoordinator.h"

@implementation KMAchievement

-(id) initWithName:(NSString *)n description:(NSString *)d points:(NSNumber *)p criteria:(XiNode*)c{
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
