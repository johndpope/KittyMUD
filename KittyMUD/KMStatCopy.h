//
//  KMStatCopy.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/8/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMStat.h"

#ifndef F
#define F(x) 1 << x
#endif

typedef enum {
	/// <summary>
	/// Copy no values.
	/// </summary>
	KMStatCopySettingsNone = 0,
	/// <summary>
	/// Copy just the name and abbreviation.
	/// </summary>
	KMStatCopySettingsName = F(0),
	/// <summary>
	/// Copy just the current value.
	/// </summary>
	KMStatCopySettingsValue = F(1),
	/// <summary>
	/// Copy just the current allocatable amount.
	/// </summary>
	KMStatCopySettingsAllocatable = F(2),
	/// <summary>
	/// Copy just whether or not this stat is changeable.
	/// </summary>
	KMStatCopySettingsChangeable = F(3),
	/// <summary>
	/// Copy the allocatable amount and whether or not is changeable.
	/// </summary>
	KMStatCopySettingsAllocationEngine = KMStatCopySettingsAllocatable | KMStatCopySettingsChangeable,
	/// <summary>
	/// Copy the current value, the allocatable amount, and whether or not its changeable.
	/// </summary>
	KMStatCopySettingsAllExceptName = KMStatCopySettingsName | KMStatCopySettingsValue | KMStatCopySettingsAllocatable | KMStatCopySettingsChangeable,
	/// <summary>
	/// Copy everything.
	/// </summary>
	KMStatCopySettingsAll = KMStatCopySettingsName | KMStatCopySettingsValue | KMStatCopySettingsAllocatable | KMStatCopySettingsChangeable
} KMStatCopySettings;

@interface KMStat (Copy)

-(void) copyStat:(KMStat*)stat;

-(void) copyStat:(KMStat*)stat withSettings:(KMStatCopySettings)settings;

@end
