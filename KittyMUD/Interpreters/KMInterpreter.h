//
//  KMInterpreter.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol KMInterpreter <NSObject>

-(void) interpret:(id)coordinator;

@end