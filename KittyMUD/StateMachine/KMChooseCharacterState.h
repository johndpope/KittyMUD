//
//  KMChooseCharacterState.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/21/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMState.h"
#import "KMAccountMenu.h"
#import "KMMenuHandler.h"
#import "KMCharacter.h"
#import "KMRoom.h"

@interface KMChooseCharacterState : NSObject <KMState,KMAccountMenu> {
	KMMenuHandler* menu;
}

-(id) init;
@property (retain) KMMenuHandler* menu;
@end
