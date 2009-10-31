//
//  KMChooseRaceState.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/5/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMState.h"
#import "KMMenuHandler.h"
#import "KMObject.h"

@interface  KMChooseRaceState  : KMObject <KMState> {
	KMMenuHandler* menu;
}

-(id)init;

@property (retain) KMMenuHandler* menu;
@end
