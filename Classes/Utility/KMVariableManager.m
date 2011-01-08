//
//  KMVariableManager.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/16/09.
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

// EC_MOVE:  This class belongs in Eternity Chronicles.  It is not important to KittyMUD and the same functionality is easily duplicated.
#import "KMVariableManager.h"
#import "NSString+KMAdditions.h"

@implementation KMVariableManager

-(id) init
{
	self = [super init];
	if(self) {
		variables = [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(id) initializeWithConfigFile:(NSString*)configFile
{
	self = [self init];
	if(self) {
		fileName = configFile;
		[self loadAllVariables];
	}
	return self;
}

-(void) loadAllVariables
{
	OCLog(@"kittymud",info,@"Reading configuration file %@...", fileName);
	NSFileHandle* configFile = [NSFileHandle fileHandleForReadingAtPath:fileName];
	if(configFile != nil) {
		NSData* rawcontents = [configFile readDataToEndOfFile];
		NSString* contents = [[NSString alloc] initWithData:rawcontents encoding:NSUTF8StringEncoding];
		NSArray* lines = [contents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		for(NSString* line in lines) {
			if([line length] <= 0)
				break;
			NSArray* parts = [line componentsSeparatedByString:@"="];
			if([line characterAtIndex:0] == '#' || [parts count] < 2)
				continue;
			NSString* name = [parts objectAtIndex:0];
			NSString* value = [parts objectAtIndex:1];
			if([value characterAtIndex:([value length] - 1)] == ';') {
				value = [value substringToIndex:([value length] - 1)];
			}
			[NSString addVariableWithKey:name andValue:value];
			[variables setObject:value forKey:name];
			OCLog(@"kittymud",info,@"Set variable $(%@) to value %@.", name, value);
		}
	}
}

-(BOOL) saveAllVariables
{
	NSFileHandle* configFile = [NSFileHandle fileHandleForWritingAtPath:fileName];
	for(NSString* key in [variables allKeys]) {
		NSString* var = [NSString stringWithFormat:@"%@=%@;\n",key,[variables objectForKey:key]];
		[configFile writeData:[var dataUsingEncoding:NSUTF8StringEncoding]];
	}
    return YES;
}

@synthesize fileName;
@synthesize variables;

@end
