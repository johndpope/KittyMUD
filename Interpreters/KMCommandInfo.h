//
//  KMCommandInfo.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/15/09.
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

#import <Cocoa/Cocoa.h>
#import "KMConnectionCoordinator.h"
#import "KMObject.h"

@interface  KMCommandInfo  : KMObject {
	NSString* method;
	NSString* name;
	NSMutableArray* optArgs;
	NSMutableArray* aliases;
	NSMutableArray* cmdflags;
	NSMutableDictionary* help;
	int minLevel;
	id target;
	KMConnectionCoordinator* coordinator;
}

-(id) init;
@property NSString* method;
@property (retain) NSString* name;
@property (retain) NSMutableArray* optArgs;
@property (retain) NSMutableArray* aliases;
@property (retain) NSMutableArray* cmdflags;
@property (retain) NSMutableDictionary* help;
@property int minLevel;
@property (retain) id target;
@property (retain) KMConnectionCoordinator* coordinator;
@end
