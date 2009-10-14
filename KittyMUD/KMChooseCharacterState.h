//
//  KMChooseCharacterState.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/21/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMMessageState.h"
#import "KMAccountMenu.h"
#import "KMMenuHandler.h"
#import "KMCharacter.h"
#import "KMRoom.h"

@interface KMChooseCharacterState : NSObject <KMMessageState,KMAccountMenu> {
	KMMenuHandler* menu;
}

-(id) init;
@end
