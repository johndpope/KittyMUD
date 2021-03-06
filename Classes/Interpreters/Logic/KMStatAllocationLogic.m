//
//  KMStatAllocationLogic.m
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

#import "KMStatAllocationLogic.h"
#import "KMConnectionCoordinator.h"
#import "KMCharacter.h"
#import "KMStatCopy.h"
#import "NSString+KMAdditions.h"
#import "KMColorProcessWriteHook.h"
#import "KMInfoDisplay.h"
#import "KMClass.h"
#import "KMConfirmStatAllocationState.h"
#import "KMBasicInterpreter.h"
#import "KMWorkflow.h"

@implementation KMStatAllocationLogic

-(void) changeStatBase:(KMConnectionCoordinator*)coordinator stat:(NSString*)stat value:(int)value type:(KMStatAllocationChangeType)type {
	KMCharacter* character = [coordinator valueForKeyPath:@"properties.current-character"];
	NSPredicate* allocatable = [NSPredicate predicateWithFormat:@"self.properties.allocatable.intValue > 0"];
	NSArray* stillAllocatable = [[[character stats] children] filteredArrayUsingPredicate:allocatable];
	if([stillAllocatable count] == 0 && type == KMStatAllocationIncrease) {
		[coordinator sendMessageToBuffer:@"No points remaining."];
		return;
	}
	
	BOOL valid = YES;
	KMStat* st =[[character stats] findStatWithPath:stat];
	
	if(st == nil || ![[st properties] objectForKey:@"changeable"])
		valid = NO;
	
	if(!valid) {
		[coordinator sendMessageToBuffer:@"Invalid stat.  Type help for more information."];
		return;
	}
	
	KMStat* baseStat = [base findStatWithPath:stat];
	int difference = 0;
	switch(type) {
		case KMStatAllocationIncrease:
			if(value > [[[st parent] valueForKeyPath:@"properties.allocatable"] intValue]) {
				[coordinator sendMessageToBuffer:@"Not enough points remaining to increase %@.",stat];
				return;
			}
			[st setStatvalue:([st statvalue] + value)];
			[[[st parent] properties] setObject:[NSNumber numberWithInt:([[[st parent] valueForKeyPath:@"properties.allocatable"] intValue] - value)] forKey:@"allocatable"];
			break;
		case KMStatAllocationDecrease:
			if( value > ([st statvalue] - [baseStat statvalue]) ) {
				[coordinator sendMessageToBuffer:@"Not enough points to decrease %@.",stat];
				return;
			}
			[st setStatvalue:([st statvalue] - value)];
			[[[st parent] properties] setObject:[NSNumber numberWithInt:([[[st parent] valueForKeyPath:@"properties.allocatable"] intValue] + value)] forKey:@"allocatable"];
			break;
		case KMStatAllocationReset:
			difference = ([st statvalue] - [baseStat statvalue]);
			[st setStatvalue:[baseStat statvalue]];
			[[[st parent] properties] setObject:[NSNumber numberWithInt:([[[st parent] valueForKeyPath:@"properties.allocatable"] intValue] + difference)] forKey:@"allocatable"];
			break;
	}
}
	 
CHELP(increase,@"Increases a stat by the given value.",nil)
CIMPL(increase,increase:stat:withValue:,nil,nil,nil,1) stat:(NSString*)stat withValue:(int)value {
	[self changeStatBase:coordinator stat:stat value:value type:KMStatAllocationIncrease];
}

CHELP(decrease,@"Decreases a stat by the given value.",nil)
CIMPL(decrease,decrease:stat:withValue:,nil,nil,nil,1) stat:(NSString*)stat withValue:(int)value {
	[self changeStatBase:coordinator stat:stat value:value type:KMStatAllocationDecrease];
}

CHELP(reset,@"Resets a stat to the starting value.",nil)
CIMPL(reset,reset:stat:,nil,nil,nil,1) stat:(NSString*)stat {
	[self changeStatBase:coordinator stat:stat value:0 type:KMStatAllocationReset];
}

CHELP(save,@"Saves the changes.  Confirms the save if you have points remaining.",nil)
CIMPL(save,save:,nil,nil,nil,1) {
	NSPredicate* allocatable = [NSPredicate predicateWithFormat:@"self.properties.allocatable > 0"];
	NSArray* stillAllocatable = [[[[coordinator valueForKeyPath:@"properties.current-character"] stats] children] filteredArrayUsingPredicate:allocatable];
	if([stillAllocatable count] > 0) {
		[coordinator sendMessageToBuffer:@"Points still remaining to allocate.  Type quit if you wish to continue without spending those points."];
		return;
	}
	[self CMD(quit)];
}

CHELP(quit,@"Quits the allocation, saves changes.  Does not confirm even if you have points remaining.",nil)
CIMPL(quit,quit:,nil,nil,nil,1) {
	BOOL ready = [self confirmStats:coordinator];	
	if( ready ) {
		KMSetStateForCoordinatorTo([KMNullState class]);
		[(KMObject*)[coordinator valueForKeyPath:@"properties.current-character"] setFlag:@"allocated"];
		return;
	}
}

CHELP(showvalid,@"Shows which stats are valid for input to the allocation commands.",nil)
CIMPL(showvalid,showvalid:,nil,@"valid",nil,1) {
	[coordinator sendMessageToBuffer:@"Valid stat names are:>"];
	for(NSString* valid in validStats) {
		[coordinator sendMessageToBuffer:valid];
	}
}

-(void) generateValidStats
{
	NSPredicate* changeableOnCollection = [NSPredicate predicateWithFormat:@"properties.changeable == yes"];
	NSArray* changeableCollection = [[allocBase children] filteredArrayUsingPredicate:changeableOnCollection];
	for(KMStat* stat in changeableCollection) {
		[validStats addObject:[NSString stringWithFormat:@"(%@|%@)",[stat name], [stat abbreviation]]];
		NSPredicate* changeableOnCollectionReverse = [NSPredicate predicateWithFormat:@"children.@count.intValue == 0 and properties.changeable == yes"];
		NSArray* changeableCollectionReverse = [[stat children] filteredArrayUsingPredicate:changeableOnCollectionReverse];
		for(KMStat* child in changeableCollectionReverse) {
			if([[[child parent] name] isEqualToString:@"main"]) {
				[validStats addObject:[NSString stringWithFormat:@"(%@|%@)",[child name], [child abbreviation]]];
			} else {
				[validStats addObject:[NSString stringWithFormat:@"(%@|%@)::(%@|%@)",[[child parent] name],[[child parent] abbreviation], [child name], [child abbreviation]]];
			}
		}
	}
}

-(id) initWithCommandInterpreter:(id) __unused cmdInterpreter
{
	self = [super init];
	if(self) {
		allocBase = [KMStat loadFromTemplateAtPath:[@"$(DataDir)/templates/stat_template.xml" replaceAllVariables] withType:KMStatLoadTypeAllocation];
		base = [[KMStat alloc] init];
		validStats = [[NSMutableArray alloc] init];
		[self generateValidStats];
		copiedAllocatable = NO;
	}
	return self;
}

-(void) displayHelpToCoordinator:(id)coordinator
{
	[coordinator sendMessageToBuffer:@"((inc)rease (dec)rease) (<stat> <number>|-help)\n"];
	[coordinator sendMessageToBuffer:@"reset (<stat>|-help)\n"];
	[coordinator sendMessageToBuffer:@"save quit valid (-help)\n"];
	[coordinator sendMessageToBuffer:@"Enter command:"];
	[(KMObject*)coordinator setFlag:@"no-message"];
}

-(void) repeatCommandsToCoordinator:(id)coordinator
{
	[self displayHelpToCoordinator:coordinator];
}

-(BOOL) isRepeating
{
	return YES;
}

-(BOOL) confirmStats:(id)coordinator {
	KMCharacter* character = [coordinator valueForKeyPath:@"properties.current-character"];
	NSArray* avail = [KMClass getAvailableJobs:character];
	
	if( [avail count] == 0 ) {
		[coordinator sendMessageToBuffer:@"No classes available for chosen stats.\n"];
		return NO;
	}
	
	int i = 0;
	
	NSMutableString* sb = [[NSMutableString alloc] init];
	[sb appendString:@"Available classes: \n"];
	for(KMClass* j in avail) {
		[sb appendFormat:@"%@ ", [j name]];
		if( i % 5 == 0 )
			[sb appendString:@"\n\r"];
		i++;
	}
	[coordinator sendMessageToBuffer:sb];
	return YES;
}

-(void) displayStatAllocationScreenToCoordinator:(id)coordinator {
	if( [coordinator isFlagSet:@"allocated"] )
	{
		__block void (^setAllocatableTo0)(KMStat*) = nil;
		
		setAllocatableTo0 = ^void(KMStat* stat) {
			[[stat properties] setObject:[NSNumber numberWithInt:0] forKey:@"allocatable"];
			if([stat hasChildren]) {
				for(KMStat* child in [stat children]) {
					setAllocatableTo0(child);
				}
			}
		};
		
		setAllocatableTo0([[coordinator valueForKeyPath:@"properties.current-character"] stats]);
	}
	
	KMStat* current = [[coordinator valueForKeyPath:@"properties.current-character"] stats];
	if(!copiedAllocatable) {
		[base copyStat:current withSettings:KMStatCopySettingsAll];
		[current copyStat:allocBase withSettings:KMStatCopySettingsAllocationEngine];
		copiedAllocatable = YES;
	}
	
	KMInfoDisplay* display = [[KMInfoDisplay alloc] init];
	NSPredicate* changeable = [NSPredicate predicateWithFormat:@"properties.changeable == yes"];
	NSArray* changeableCollections = [[current children] filteredArrayUsingPredicate:changeable];
	NSMutableString* allocatabledisplay = [[NSMutableString alloc] init];
	for(KMStat* stat in changeableCollections)
		[allocatabledisplay appendFormat:@"%@ ",[stat name]];
	
	NSString* titleLine = [NSString stringWithFormat:@" `cmain `WAllocatable remaining`w: `G%d `WAllocatable to `c%@`x", [[current valueForKeyPath:@"properties.allocatable"] intValue], allocatabledisplay];
	
	[display appendSeperator];
	[display appendLine:titleLine];
	[display appendSeperator];
	
	for(KMStat* stat in changeableCollections) {
		NSString* childDisplay = @"";
		if([stat hasChildren]) {
			childDisplay = [NSString stringWithFormat:@"`w(`WAllocatable to children: `c%d`w)", [[stat valueForKeyPath:@"properties.allocatable"] intValue]];
		}
		NSString* allocatableEntry = [NSString stringWithFormat:@"    `c%@: `G%d %@", [stat name], [stat statvalue],childDisplay];
		[display appendLine:allocatableEntry];
		
		NSPredicate* allocatableChildrenP = [NSPredicate predicateWithFormat:@"children.@count == 0 and properties.changeable == yes"];
		NSArray* allocatableChildren = [[stat children] filteredArrayUsingPredicate:allocatableChildrenP];
		
		for(KMStat* child in allocatableChildren) {
			NSString* childEntry = [NSString stringWithFormat:@"        `c%@: `G%d`x", [child name], [child statvalue]];
			[display appendLine:childEntry];
		}
	}
	
	int i = 0;
	NSPredicate* allocatable = [NSPredicate predicateWithFormat:@"properties.allocatable.intValue > 0"];
	NSArray* stillAllocatable = [[[[coordinator valueForKeyPath:@"properties.current-character"] stats] children] filteredArrayUsingPredicate:allocatable];
	for(KMStat* stat in stillAllocatable)
		i += [[stat valueForKeyPath:@"properties.allocatable"] intValue];
	
	i += [[current valueForKeyPath:@"properties.allocatable"] intValue];
	
	[display appendSeperator];
	NSString* statusDisplay = [NSString stringWithFormat:@" `WTotal allocation points remaing: `G%d `yinc dec reset quit save valid`x", i];
	[display appendLine:statusDisplay];
	[display appendSeperator];
	[display appendString:@"`wEnter command`x:"];
	[coordinator sendMessageToBuffer:[display finalOutput]];
}
@synthesize base;
@synthesize allocBase;
@synthesize copiedAllocatable;
@synthesize validStats;
@end
