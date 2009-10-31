//
//  KMObject.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/31/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//

#import "KMObject.h"
#import <objc/runtime.h>

@interface NSObject (private)

+(BOOL) addMethod:(SEL)aSelector toClass:(Class)aClass error:(NSError **)error;

+(BOOL) addToClass:(Class)aClass error:(NSError **)error;

@end

@implementation KMObject

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
		if(res)
			[invocation invokeWithTarget:self];
	}
	[super forwardInvocation:invocation];
}

@end
