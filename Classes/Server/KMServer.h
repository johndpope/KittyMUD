//
//  KMServer.h
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
#import <CoreFoundation/CoreFoundation.h>
#import "KMConnectionPool.h"
#import "KMObject.h"

NSString* const KMServerErrorDomain;

typedef enum {
    kKMServerCouldNotBindToAddress = 1,
    kKMServerNoSocketsAvailable = 2,
} KMServerErrorCode;

@interface  KMServer  : NSObject {
	@private
	CFSocketRef serverSocket;
	int currentPoolId;
	KMConnectionPool* connectionPool;
	BOOL isRunning;
}

+(KMServer*)defaultServer;

-(id) init;

-(BOOL) initializeServerWithPort:(int)port error:(NSError**)error;

-(void) shutdown;

-(void) softReboot;

-(void) softRebootRecovery:(CFSocketNativeHandle)socketHandle;

@property CFSocketRef serverSocket;
@property int currentPoolId;
@property (retain) KMConnectionPool* connectionPool;
@property BOOL isRunning;
@end
