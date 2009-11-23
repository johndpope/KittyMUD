//
//  KMObject.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/31/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//

#import "KMObject.h"
#import "KMConnectionCoordinator.h"
#import <XDF/XDF.h>
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
	[XDFCodingAspect addToClass:[self class] error:&error];
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
