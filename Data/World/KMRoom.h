//
//  KMRoom.h
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
#import "KMExitInfo.h"
#import "KMDataStartup.h"
#import "KMDataManager.h"
#import "KMObject.h"

@interface  KMRoom  : KMObject <KMDataStartup,KMDataCustomLoader> {
	NSString* roomID;
	NSMutableArray* exitInfo;
	NSString* roomTitle;
	NSString* roomDescription;
	NSString* sector;
	BOOL isDefault;
}

-(id) init;

+(void) resolveExits:(BOOL)remove;

+(NSArray*) getAllRooms;

+(NSArray*) loadRoomWithPath:(NSString*)path;

+(KMRoom*) getRoomByName:(NSString*)name;

+(KMRoom*) getDefaultRoom;

-(NSString*) stringValue;

-(KMExitInfo*) getExit:(KMExitDirection)direction;

-(void) displayRoom:(id)coordinator;

@property (retain,readonly) NSMutableArray* exitInfo;
@property (copy) NSString* roomID;
@property (copy) NSString* roomTitle;
@property (copy) NSString* roomDescription;
@property (assign) BOOL isDefault;
@property (copy) NSString* sector;

@end
