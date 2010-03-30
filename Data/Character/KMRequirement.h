//
//  KMRequirement.h
//  KittyMUD
//
//  Created by Michael Tindal on 3/19/10.
//  Copyright 2010 Michael Tindal. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMObject.h"
#import "KMCharacter.h"

@interface KMRequirement : KMObject {

}

-(BOOL) resolveWithCharacter:(KMCharacter*)character;

@end
