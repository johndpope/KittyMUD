//
//  KMObject.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/31/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//

#import "KMObject.h"
#import "KMConnectionCoordinator.h"
#import <objc/runtime.h>

@interface NSObject (private)

+(BOOL) addMethod:(SEL)aSelector toClass:(Class)aClass error:(NSError **)error;

+(BOOL) addToClass:(Class)aClass error:(NSError **)error;

@end

@implementation KMObject

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
		[coordinator sendMessageToBuffer:[NSString stringWithFormat:@"Flag %@: %@", flag, flagstatus]];
	}
}

-(BOOL) respondsToSelector:(SEL)aSelector {
	SEL selector = aSelector;
	Class c = NSClassFromString(@"XDFCodingAspect");
	if(([NSStringFromSelector(selector) isEqualTo:NSStringFromSelector(@selector(encodeWithCoder:))] ||
		[NSStringFromSelector(selector) isEqualTo:NSStringFromSelector(@selector(initWithCoder:))]) && c) {
		NSError* error = [[NSError alloc] init];
		BOOL res = [c addToClass:[self class] error:&error];
		if(res)
			return YES;
	}
	return [super respondsToSelector:selector];
}

-(BOOL) conformsToProtocol:(Protocol *)aProtocol {
	Class c = NSClassFromString(@"XDFCodingAspect");
	if([NSStringFromProtocol(aProtocol) isEqualTo:NSStringFromProtocol(@protocol(NSCoding))] && c)
	{
		NSError* error = [[NSError alloc] init];
		BOOL res = [c addToClass:[self class] error:&error];
		if(res)
			return YES;
	}
	return [super conformsToProtocol:aProtocol];
}

-(void) forwardInvocation:(NSInvocation*)invocation {
	SEL selector = [invocation selector];
	Class c = NSClassFromString(@"XDFCodingAspect");
	if(([NSStringFromSelector(selector) isEqualTo:NSStringFromSelector(@selector(encodeWithCoder:))] ||
	   [NSStringFromSelector(selector) isEqualTo:NSStringFromSelector(@selector(initWithCoder:))]) && c) {
		NSError* error = [[NSError alloc] init];
		BOOL res = [c addToClass:[self class] error:&error];
		if(res) {
			[invocation invokeWithTarget:self];
			return;
		}
	}
	[super forwardInvocation:invocation];
}

-(NSMethodSignature*) methodSignatureForSelector:(SEL)selector {
	Class c = NSClassFromString(@"XDFCodingAspect");
	if(([NSStringFromSelector(selector) isEqualTo:NSStringFromSelector(@selector(encodeWithCoder:))] ||
		[NSStringFromSelector(selector) isEqualTo:NSStringFromSelector(@selector(initWithCoder:))]) && c) {
		NSError* error = [[NSError alloc] init];
		BOOL res = [c addToClass:[self class] error:&error];
		if(res) {
			return [self methodSignatureForSelector:selector];
		}
	}
	return [super methodSignatureForSelector:selector];
}

@synthesize properties;

@end
