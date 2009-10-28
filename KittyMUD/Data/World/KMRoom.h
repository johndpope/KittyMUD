//
//  KMRoom.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/12/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMExitInfo.h"
#import "KMDataStartup.h"
#import "KMDataManager.h"

@interface KMRoom : NSObject <KMDataStartup,KMDataCustomLoader> {
	NSString* roomID;
	NSMutableArray* exitInfo;
	NSString* roomTitle;
	NSString* roomDescription;
	NSString* sector;
	NSMutableDictionary* properties;
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
@property (retain,readonly) NSMutableDictionary* properties;
@property (assign) BOOL isDefault;
@property (copy) NSString* sector;

@end
