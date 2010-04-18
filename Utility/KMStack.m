//
//  KMStack.m
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

#import "KMStack.h"


@implementation KMStack

-(id) init
{
	self = [super init];
	if(self) {
		items = [[NSMutableArray alloc] init];
	}
	return self;
}

-(id) pop
{
	if([items count] == 0)
		return nil;
	
	id item = [items objectAtIndex:0];
	[items removeObjectAtIndex:0];
	return item;
}

-(void) push:(id)obj
{
	[items insertObject:obj atIndex:0];
}

-(id) peek
{
	if([items count] == 0)
		return nil;
	
	id item = [items objectAtIndex:0];
	return item;
}

@synthesize items;
@end
