//
//  KMObject.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/31/09.
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


@interface  KMObject  : NSObject {
	NSMutableDictionary* properties;
	NSMutableArray* flagbase;
	NSMutableDictionary* flags;
	NSMutableDictionary* flagreasons;
	unsigned int currentbitpower;
}

-(BOOL) isFlagSet:(NSString*)flagName;

-(void) setFlag:(NSString*)flagName;

-(void) setFlag:(NSString *)flagName reason:(NSString*)reason;

-(NSString*) reasonForFlag:(NSString *)flagName;

-(void) clearFlag:(NSString*)flagName;

-(void) debugPrintFlagStatus:(id)coordinator;

@property (retain,readonly) NSMutableDictionary* properties;

@end

#ifndef N
#define N(n) [NSNumber numberWithFloat:n]
#endif

#ifndef I
#define I(n) [NSNumber numberWithInt:n]
#endif

#ifndef BL
#define BL(n) [NSNumber numberWithBool:n]
#endif