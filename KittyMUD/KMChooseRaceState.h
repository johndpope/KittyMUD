//
//  KMChooseRaceState.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/5/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMMessageState.h"
#import "KMMenuHandler.h"

@interface KMChooseRaceState : NSObject <KMMessageState> {
	KMMenuHandler* menu;
}

-(id)init;

@end
