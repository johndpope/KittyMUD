//
//  KMExitInfo.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/12/09.
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

#import <Cocoa/Cocoa.h>
#import "KMObject.h"

typedef enum {
	KMExitNorth = 0,
	KMExitSouth = 1,
	KMExitWest = 2,
	KMExitEast = 3,
	KMExitUp = 4,
	KMExitDown = 5
} KMExitDirection;

@interface  KMExitInfo  : KMObject {
	KMExitDirection direction;
	NSString* lockId;
	BOOL isLocked;
	NSString* destination;
	id room;
}

@property (assign) KMExitDirection direction;
@property (copy) NSString* lockId;
@property (assign) BOOL isLocked;
@property (copy) NSString* destination;
@property (retain) id room;
@end
