//
//  KMState.m
//  KittyMUD
//
//  Created by Michael Tindal on 4/5/10.
//  Copyright 2010 Michael Tindal. All rights reserved.
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

-(NSString*) stringValue {
    return [[self class] getName];
}

@synthesize coordinator;

@end
