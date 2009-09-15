//
//  KMStateMachine.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMConnectionCoordinator.h"

@protocol KMState <NSObject>

-(id<KMState>) processState:(KMConnectionCoordinator*)coordinator withInput:(NSString*)input;

-(NSString*) getName;

@end
