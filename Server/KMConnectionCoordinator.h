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

@interface  KMConnectionCoordinator  : KMObject {
	@private
	CFSocketRef socket;
	NSString* inputBuffer;
	NSString* outputBuffer;
	NSDate* lastReadTime;
	NSMutableArray* characters;
}

+(KMConnectionCoordinator*) getCoordinatorForCharacterWithName:(NSString*)name;

-(id) init;

-(BOOL) sendMessage:(NSString*)message,...;

-(void) sendMessageToBuffer:(NSString*)message,...;

-(CFSocketRef) getSocket;

-(void) setSocket:(CFSocketRef)newSocket;

-(BOOL) createSocketWithHandle:(CFSocketNativeHandle)handle andCallback:(CFSocketCallBack)callback;

-(void) saveToXML:(NSString*)path;

-(void) loadFromXML:(NSString*)path;

// -(id) valueForUndefinedKey:(NSString *)key;

// -(void) setValue:(id)value forUndefinedKey:(NSString*)key;

-(void) releaseSocket;

@property (copy,getter=getLastReadTime) NSDate* lastReadTime;
@property (copy,getter=getInputBuffer) NSString* inputBuffer;
@property (getter=getSocket,setter=setSocket:) CFSocketRef socket;
@property (copy) NSString* outputBuffer;
@property (retain,readonly,getter=getCharacters) NSMutableArray* characters;
@end
