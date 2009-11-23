//
//  KMStateMachine.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/15/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KMState <NSObject>

+(void) processState:(id)coordinator;

+(NSString*) getName;

// Because soft reboot under KittyMUD does not discriminate based on the state, we use this so we can remind players what they were doing after a soft reboot
+(void) softRebootMessage:(id)coordinator;

@end

extern NSMutableDictionary* interpreters;

#define KMSetMenuForCoordinatorTo(m) do { \
	[coordinator setValue:m forKeyPath:@"properties.menu"]; \
} while(0)

#define KMGetMenuFromCoordinator(m) KMMenuHandler* m = [coordinator valueForKeyPath:@"properties.menu"]

#define KMSLGetMenuFromCoordinator(m) m = [coordinator valueForKeyPath:@"properties.menu"]

#define KMSetStateForCoordinatorTo(s) do { \
	[coordinator setValue:[s class] forKeyPath:@"properties.current-state"]; \
} while(0)

#define KMGetStateFromCoordinator(s) id<KMState> s = [coordinator valueForKeyPath:@"properties.current-state"]

#define KMSetInterpreterForStateTo(s,i) do { \
	[interpreters setValue:i forKey:[[[s class] class] getName]]; \
} while(0)
	
#define KMGetInterpreterForState(s,l) id<KMInterpreter> l = [interpreters valueForKey:[[[s class] class] getName]];