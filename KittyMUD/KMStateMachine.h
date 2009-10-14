//
//  KMStateMachine.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/13/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMState.h"

@interface KMStateMachine : NSObject {

}

+(id<KMState>) getState:(NSString*)state;

+(void) registerState:(id<KMState>)state;
@end
