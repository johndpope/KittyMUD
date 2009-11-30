//
//  KMInfoManager.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/11/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
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
