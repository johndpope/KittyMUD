//
//  KMInterpreter.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/17/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol KMInterpreter <NSObject>

-(void) interpret:(id)coordinator;

@end

#define KMGetInterpreterForCoordinator(i) id<KMInterpreter> i = [coordinator valueForKeyPath:@"properties.current-interpreter"]

#define KMSetInterpreterForCoordinatorTo(i) do { \
	[coordinator setValue:i forKeyPath:@"properties.current-interpreter"]; \
} while(0)