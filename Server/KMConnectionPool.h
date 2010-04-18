//
//  KMConnectionPool.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/12/09.
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
#import "KMConnectionCoordinator.h"
#import "KMWriteHook.h"
#import "KMObject.h"
#import "KMState.h"

NSString* const KMConnectionPoolErrorDomain;

typedef enum {
	kKMConnectionPoolCouldNotCreateSocket = 1,
} KMConnectionPoolErrorCodes;

typedef void (^KMConnectionReadCallback) (id);

@interface  KMConnectionPool  : NSObject {
	NSMutableArray* connections;
	NSMutableArray* hooks;
	KMConnectionReadCallback readCallback;
	NSString* greeting;
	id<KMState> defaultState;
}

-(id) init;

-(KMConnectionCoordinator*) newConnectionWithSocketHandle:(CFSocketNativeHandle) handle softReboot:(BOOL)softReboot;

-(KMConnectionCoordinator*) newConnectionWithSocketHandle:(CFSocketNativeHandle)handle softReboot:(BOOL)softReboot withName:(NSString*)name;

-(void) writeToAllConnections:(NSString*)message;

-(void) removeConnection:(KMConnectionCoordinator*)connection;

-(void) checkOutputBuffers:(NSTimer*)timer;

-(void) addHook:(id<KMWriteHook>)hook;

-(void) removeHook:(id<KMWriteHook>)hook;

@property (retain) NSMutableArray* connections;
@property (retain) NSMutableArray* hooks;
@property (copy) KMConnectionReadCallback readCallback;
@property (retain) NSString* greeting;
@property (retain) id<KMState> defaultState;
@end
