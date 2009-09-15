//
//  KMGameEngine.h
//  KittyMUD
//
//  Created by Michael Tindal on 8/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef void (*KMEngineHook) (void);

typedef struct {
	int* _maxTimer;
	int* _currentTimer;
	KMEngineHook _hook;
} KMTimedEngineHook;

// The main interface for KittyMUD.  Everything will go through here.
@interface KMGameEngine : NSObject {
	NSMutableArray* timedHooks;
}

@end
