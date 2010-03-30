//
//  KMBasicInterpreter.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/17/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMInterpreter.h"
#import "KMObject.h"

@interface  KMBasicInterpreter  : KMObject <KMInterpreter> {

}

-(void) interpret:(id)coordinator withOldState:(id)state;

@end
