//
//  KMAccountMenuState.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMMessageState.h"
#import "KMMenuHandler.h"

@interface KMAccountMenuState : NSObject <KMMessageState> {
	NSMutableArray* myItems;
	KMMenuHandler* menu;
}

-(id) initializeWithCoordinator:(id)coordinator;

@property (copy) NSMutableArray* myItems;
@end
