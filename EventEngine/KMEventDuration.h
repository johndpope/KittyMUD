//
//  KMEventDuration.h
//  KittyMUD
//
//  Created by Michael Tindal on 1/29/10.
//  Copyright 2010 Michael Tindal. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMCharacter.h"

@interface KMEventDuration : NSObject {
	KMCharacter* owner;
}

+(KMEventDuration*) untilEndOfNextTurn;

+(KMEventDuration*) once;

+(KMEventDuration*) untilNextAttackRollAgainstTarget:(id)t;

+(KMEventDuration*) untilEndOfNextTurnForCharacter:(KMCharacter*)c;

+(KMEventDuration*) untilNextAttackRoll;

+(KMEventDuration*) permanent;

+(KMEventDuration*) untilAttackIsFinished;

+(KMEventDuration*) untilLevelUp;


@end
