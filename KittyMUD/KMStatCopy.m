//
//  KMStatCopy.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/8/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMStatCopy.h"


@implementation KMStat (Copy)

-(void) copyStat:(KMStat*)stat
{
	[self copyStat:stat withSettings:KMStatCopySettingsAllExceptName];
}

-(void) copyStat:(KMStat*)stat withSettings:(KMStatCopySettings)settings
{
	if(!stat)
		return;
	
	if(settings & KMStatCopySettingsName)
	{
		[self setName:[stat name]];
		[self setAbbreviation:[stat abbreviation]];
	}
	if(settings & KMStatCopySettingsValue)
		[self setStatvalue:[stat statvalue]];
	if(settings & KMStatCopySettingsChangeable && [stat valueForKeyPath:@"properties.changeable"])
		[[self getProperties] setObject:[[stat getProperties] objectForKey:@"changeable"] forKey:@"changeable"];
	if(settings & KMStatCopySettingsAllocatable && [stat valueForKeyPath:@"properties.allocatable"])
		[[self getProperties] setObject:[[stat getProperties] objectForKey:@"allocatable"] forKey:@"allocatable"];
	if([stat hasChildren]) {
		for(KMStat* child in [stat getChildren]) {
			if([child name] == nil || [child abbreviation] == nil)
				continue;
			KMStat* mychild = [self findStatWithPath:[child name]];
			BOOL toAdd = NO;
			if(!mychild) {
				mychild = [[KMStat alloc] init];
				toAdd = YES;
			}
			[mychild copyStat:child withSettings:settings];
			if(toAdd)
				[self addChild:mychild];
		}
	}
}
@end
