//
//  KMExitInfo.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/12/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
	KMExitNorth = 0,
	KMExitSouth = 1,
	KMExitWest = 2,
	KMExitEast = 3,
	KMExitUp = 4,
	KMExitDown = 5
} KMExitDirection;

@interface KMExitInfo : NSObject {
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
