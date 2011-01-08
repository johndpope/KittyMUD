//
//  KMColorProcessWriteHook.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/14/09.
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

#import "KMColorProcessWriteHook.h"


@implementation KMColorProcessWriteHook

-(id) init
{
	colors = [NSDictionary dictionaryWithObjectsAndKeys:@"\x1B[0;30m", @"`k",
			  @"\x1B[0;31m", @"`r",
			  @"\x1B[0;32m", @"`g",
			  @"\x1B[0;33m", @"`y",
			  @"\x1B[0;34m", @"`b",
			  @"\x1B[0;35m", @"`m",
			  @"\x1B[0;36m", @"`c",
			  @"\x1B[0;37m", @"`w",
			  @"\x1B[1;30m", @"`K",
			  @"\x1B[1;31m", @"`R",
			  @"\x1B[1;32m", @"`G",
			  @"\x1B[1;33m", @"`Y",
			  @"\x1B[1;34m", @"`B",
			  @"\x1B[1;35m", @"`M",
			  @"\x1B[1;36m", @"`C",
			  @"\x1B[1;37m", @"`W",
			  @"\x1B[0;40m", @"!k",
			  @"\x1B[1;40m", @"!K",
			  @"\x1B[0;41m", @"!r",
			  @"\x1B[1;41m", @"!R",
			  @"\x1B[0;42m", @"!g",
			  @"\x1B[1;42m", @"!G",
			  @"\x1B[0;43m", @"!y",
			  @"\x1B[1;43m", @"!Y",
			  @"\x1B[0;44m", @"!b",
			  @"\x1B[1;44m", @"!B",
			  @"\x1B[0;45m", @"!m",
			  @"\x1B[1;45m", @"!M",
			  @"\x1B[0;46m", @"!c",
			  @"\x1B[1;46m", @"!C",
			  @"\x1B[0;47m", @"!w",
			  @"\x1B[1;47m", @"!W",
			  @"\t", @"`#",
			  @"\n\r", @"`@",
			  @"\x1B[0m", @"`x", 
			  @"\x1B[5m", @"`!",
			  @"\x1B[25m", @"#!",nil];
	return self;
}

-(NSString*) processHook:(NSString*)input
{
	return [self processHook:input replace:YES];
}

-(NSString*) processHook:(NSString*)input replace:(BOOL)rep
{
	for(NSString* key in [colors allKeys]) {
		input = [input stringByReplacingOccurrencesOfString:key withString:(rep ? [colors objectForKey:key] : @"")];
	}
	return input;
}

@synthesize colors;
@end
