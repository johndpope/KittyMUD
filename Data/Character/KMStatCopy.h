//
//  KMStatCopy.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/8/09.
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
