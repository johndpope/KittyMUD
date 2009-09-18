//
//  KMMessageState.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMState.h"

@protocol KMMessageState <KMState>

-(void) sendMessageToCoordinator:(id)coordinator;

@end
