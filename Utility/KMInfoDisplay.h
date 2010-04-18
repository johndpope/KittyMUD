//
//  KMInfoManager.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/11/09.
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
#import "KMObject.h"

@interface  KMInfoDisplay  : KMObject {
	NSMutableString* display;
	NSString* oldColor;
}

-(id) init;

-(void) appendSeperator;

-(void) appendLine:(NSString*)line;

-(void) appendString:(NSString*)string;

-(NSString*) finalOutput;

@property (retain) NSMutableString* display;
@end
