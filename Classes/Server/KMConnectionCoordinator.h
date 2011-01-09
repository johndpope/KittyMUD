//
//  KMConnectionCoordinator.h
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
#import "KMState.h"
#import "KMInterpreter.h"
#import "KMObject.h"

@class KMConnectionCoordinator;

typedef void(^KMOutputHook)(KMConnectionCoordinator*);

@interface  KMConnectionCoordinator  : KMObject {
	@private
	CFSocketRef socket;
	NSString* inputBuffer;
	NSString* outputBuffer;
	NSDate* lastReadTime;
	NSMutableArray* characters;
    NSMutableDictionary* outputHooks;
}

+(KMConnectionCoordinator*) getCoordinatorForCharacterWithName:(NSString*)name;

-(id) init;

-(BOOL) sendMessage:(NSString*)message,...;

-(void) sendMessageToBuffer:(NSString*)message,...;

-(CFSocketRef) getSocket;

-(void) setSocket:(CFSocketRef)newSocket;

-(BOOL) createSocketWithHandle:(CFSocketNativeHandle)handle andCallback:(CFSocketCallBack)callback;

-(void) saveToXML:(NSString*)path;

-(void) saveToXML:(NSString*)path withState:(BOOL)state;

-(void) loadFromXML:(NSString*)path;

-(void) loadFromXML:(NSString*)dirToSave withState:(BOOL)state;

// -(id) valueForUndefinedKey:(NSString *)key;

// -(void) setValue:(id)value forUndefinedKey:(NSString*)key;

-(void) releaseSocket;

-(void) addOutputHook:(NSString*)key block:(KMOutputHook)hook;

@property (copy) NSDate* lastReadTime;
@property (copy) NSString* inputBuffer;
@property (copy) NSString* outputBuffer;
@property (retain,readonly) NSMutableArray* characters;
@property (retain,readonly) NSMutableDictionary* outputHooks;
@end
