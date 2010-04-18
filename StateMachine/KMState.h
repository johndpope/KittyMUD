//
//  KMStateMachine.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/15/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as 
// published by the Free Software Foundation; either version 3 of 
// the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
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
