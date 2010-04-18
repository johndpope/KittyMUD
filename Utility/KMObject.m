//
//  KMObject.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/31/09.
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

#import "KMObject.h"
#import "KMConnectionCoordinator.h"
#import <ECScript/ECScript.h>
#import <objc/runtime.h>

@interface NSObject (private)

+(BOOL) addMethod:(SEL)aSelector toClass:(Class)aClass error:(NSError **)error;

+(BOOL) addToClass:(Class)aClass error:(NSError **)error;

#ifdef USE_XDF
+(void) myinitialize;
#endif
@end

@implementation KMObject

static BOOL setUpOCLChannel = NO;
+(void) initialize {
	if(!setUpOCLChannel) {
		setUpOCLChannel = YES;
		[[OCLogMaster defaultMaster] registerChannel:[OCLogChannel channelWithName:@"kittymud"]];
	}
#ifdef USE_XDF
	NSError* error = nil;
	[ECSCodingSupportAspect addToClass:[self class] error:&error];
	if(error) {
		OCLog(@"kittymud",warning,@"Error adding support to %@...",NSStringFromClass([self class]));
	}
#endif
}

-(id)init {
	self = [super init];
	if(self) {
		properties = [[NSMutableDictionary alloc] init];
		flags = [[NSMutableDictionary alloc] init];
		flagbase = [[NSMutableArray alloc] init];
		flagreasons = [[NSMutableDictionary alloc] init];
		[flagbase addObject:[NSNumber numberWithUnsignedLongLong:0]];
		currentbitpower = 0;
	}
	return self;
}

-(BOOL) isFlagSet:(NSString*)flagName
{
	NSString* fp = [flags objectForKey:flagName];
	int flagpower = -1;
	if(fp == nil)
		return NO;
	flagpower = [fp intValue];
	
	return (1ULL << (flagpower % 64)) == ([[flagbase objectAtIndex:(flagpower / 64)] unsignedLongLongValue] & (1ULL << (flagpower % 64)));
}

-(void) setFlag:(NSString*)flagName
{
	NSString* fp = [flags objectForKey:flagName];
	int flagpower = -1;
	if( fp != nil )
		flagpower = [fp intValue];
	else {
		[flags setObject:[NSString stringWithFormat:@"%d", currentbitpower] forKey:flagName];
		if([flagbase count] <= ((currentbitpower) / 64))
			[flagbase addObject:[NSNumber numberWithUnsignedLongLong:0]];
		flagpower = currentbitpower++;
	}
	[flagbase replaceObjectAtIndex:(flagpower / 64) withObject:[NSNumber numberWithUnsignedLongLong:[[flagbase objectAtIndex:(flagpower / 64)] unsignedLongLongValue] | (1ULL << (flagpower % 64))]];
}

-(void) setFlag:(NSString*)flagName reason:(NSString*)reason {
	[self setFlag:flagName];
	[flagreasons setObject:reason forKey:flagName];
}

-(NSString*) reasonForFlag:(NSString*)flagName {
	return [flagreasons objectForKey:flagName];
}
	
-(void) clearFlag:(NSString*)flagName
{
	NSString* fp = [flags objectForKey:flagName];
	int flagpower = -1;
	if( fp == nil )
		return;
	flagpower = [fp intValue];
	if([self isFlagSet:flagName])
		[flagbase replaceObjectAtIndex:(flagpower / 64) withObject:[NSNumber numberWithUnsignedLongLong:[[flagbase objectAtIndex:(flagpower / 64)] unsignedLongLongValue] ^ (1ULL << (flagpower % 64))]];
}

-(void) debugPrintFlagStatus:(id)coordinator
{
	for(NSString* flag in [flags allKeys])
	{
		NSString* flagstatus;
		if([self isFlagSet:flag])
			flagstatus = @"SET";
		else
			flagstatus = @"CLEAR";
		[coordinator sendMessageToBuffer:@"Flag %@: %@", flag, flagstatus];
	}
}

@synthesize properties;

@end
