//
//  KMInfoManager.m
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

#import "KMInfoDisplay.h"
#import "NSString+KMAdditions.h"


@implementation KMInfoDisplay

-(id) init {
	self = [super init];
	if(self)
	{
		display = [[NSMutableString alloc] init];
		oldColor = @"";
	}
	return self;
}

-(void) appendSeperator
{
	[display appendString:@"`w+------------------------------------------------------------------------------+`x\n\r"];
}

-(void) appendLine:(NSString*)line
{
	if(([line length] + 4) >= 80) {
		NSArray* components = [line componentsSeparatedByString:@" "];
		NSMutableString* tmpLine = [NSMutableString string];
		int i = 1;
		NSString* areWeTooLong;
		[tmpLine appendString:[components objectAtIndex:0]];
		int o;
		oldColor = @"";
		do {
			o = i;
			areWeTooLong = [NSString stringWithFormat:@"%@ %@",tmpLine,[components objectAtIndex:i]];
			if(([areWeTooLong length] + 4)  < 80) {
				NSString* c = [components objectAtIndex:i++];
				NSRange colorRange = [c rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"`"]];
				if(colorRange.location != NSNotFound) {
					oldColor = [c substringWithRange:NSMakeRange(colorRange.location,2)];
				}
				[tmpLine appendString:[NSString stringWithFormat:@" %@",c]];
			}
		} while(o != i);
		NSString* lineToAppend = [NSString stringWithFormat:@"`w| %@", tmpLine];
		lineToAppend = [NSString stringWithFormat:@"%@%@`w |`x\n\r", lineToAppend, [lineToAppend getSpacing]];
		[display appendString:lineToAppend];
		NSString* rest = [[components subarrayWithRange:NSMakeRange(i,[components count]-i)] componentsJoinedByString:@" "];
		[self appendLine:[NSString stringWithFormat:@"  %@%@",oldColor, rest]];
	} else {
		NSString* lineToAppend = [NSString stringWithFormat:@"`w| %@%@", oldColor,line];
		lineToAppend = [NSString stringWithFormat:@"%@%@`w |`x\n\r", lineToAppend, [lineToAppend getSpacing]];
		[display appendString:lineToAppend];
	}
}

-(void) appendString:(NSString*)string
{
	[display appendString:string];
}

-(NSString*) finalOutput
{
	return (NSString*)display;
}

@synthesize display;
@end
