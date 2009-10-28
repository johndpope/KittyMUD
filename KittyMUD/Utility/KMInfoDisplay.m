//
//  KMInfoManager.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/11/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMInfoDisplay.h"
#import "KMString.h"


@implementation KMInfoDisplay

-(id) init {
	self = [super init];
	if(self)
	{
		display = [[NSMutableString alloc] init];
	}
	return self;
}

-(void) appendSeperator
{
	[display appendString:@"`w+------------------------------------------------------------------------------+`x\n\r"];
}

-(void) appendLine:(NSString*)line
{
	NSString* lineToAppend = [NSString stringWithFormat:@"`w|%@", line];
	lineToAppend = [NSString stringWithFormat:@"%@%@`w|`x\n\r", lineToAppend, [lineToAppend getSpacing]];
	[display appendString:lineToAppend];
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
