//
//  KMStateMachine.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/15/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMObject.h"

@class KMConnectionCoordinator;

@interface KMState : KMObject
{
	KMConnectionCoordinator* coordinator;
}

+(NSString*) getName;

-(id) initWithCoordinator:(id)coord;

@property (retain) KMConnectionCoordinator* coordinator;

@end

@protocol KMState <NSObject>

-(id) initWithCoordinator:(KMConnectionCoordinator*)coord;

+(NSString*) getName;

-(void) processState;

// Because soft reboot under KittyMUD does not discriminate based on the state, we use this so we can remind players what they were doing after a soft reboot
-(void) softRebootMessage;

@end

extern NSMutableDictionary* interpreters;

#define KMSetMenuForCoordinatorTo(m) do { \
	[coordinator setValue:m forKeyPath:@"properties.menu"]; \
} while(0)

#define KMGetMenuFromCoordinator(m) KMMenuHandler* m = [coordinator valueForKeyPath:@"properties.menu"]

#define KMSLGetMenuFromCoordinator(m) m = [coordinator valueForKeyPath:@"properties.menu"]

#define KMSetStateForCoordinatorTo(s) do { \
	id st = s; \
	[coordinator setValue:[[st alloc] initWithCoordinator:coordinator] forKeyPath:@"properties.current-state"]; \
} while(0)

#define KMGetStateFromCoordinator(s) id<KMState> s = [coordinator valueForKeyPath:@"properties.current-state"];

#define KMSetInterpreterForStateTo(s,i) do { \
	[interpreters setValue:i forKey:[[s class] getName]]; \
} while(0)
	
#define KMGetInterpreterForState(s,l) id<KMInterpreter> l = [interpreters valueForKey:[[s class] getName]];

@interface KMNullState : KMState <KMState>

@end
