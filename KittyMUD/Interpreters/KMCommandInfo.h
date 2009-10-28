//
//  KMCommandInfo.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/15/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMConnectionCoordinator.h"

@interface KMCommandInfo : NSObject {
	NSString* method;
	NSString* name;
	NSMutableArray* optArgs;
	NSMutableArray* aliases;
	NSMutableArray* flags;
	NSMutableDictionary* help;
	int minLevel;
	id target;
	KMConnectionCoordinator* coordinator;
}

-(id) init;
@property NSString* method;
@property (retain) NSString* name;
@property (retain) NSMutableArray* optArgs;
@property (retain) NSMutableArray* aliases;
@property (retain) NSMutableArray* flags;
@property (retain) NSMutableDictionary* help;
@property int minLevel;
@property (retain) id target;
@property (retain) KMConnectionCoordinator* coordinator;
@end