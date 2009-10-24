//
//  NSCodingAspect.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/15/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "NSCodingAspect.h"


@implementation NSCodingAspect

+ (BOOL) addMethod:(SEL)aSelector toClass:(Class)aClass error:(NSError **)error {
	IMP implementation = class_getMethodImplementation([self class], aSelector);
	Method method = class_getInstanceMethod([self class], aSelector);
	BOOL worked = class_addMethod(aClass, aSelector, implementation, method_getTypeEncoding(method));
	if (!worked) {
		if(error)
			*error = [NSError errorWithDomain:NSStringFromClass(aClass) 
										 code:0 
									 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Error adding method: %@", 
																				  NSStringFromSelector(aSelector)] 
																		  forKey:@"errMsg"]];
	} else {
		error = nil;
	}
	if(!error)
		return YES;
	return NO;
}

+ (BOOL) addToClass:(Class)aClass error:(NSError **)error {
	Protocol * codingProtocol = objc_getProtocol("NSCoding");
	BOOL classConforms = class_conformsToProtocol(aClass, codingProtocol);
	
	NSError* errorTmp = nil;
	if(!error) {
		errorTmp = [[NSError alloc] init];
		error = &errorTmp;
	}
	
	if (!classConforms) {
		class_addProtocol(aClass, codingProtocol);
		
		if (!class_getInstanceMethod(aClass, @selector(initWithCoder:))) {
			[NSCodingAspect addMethod:@selector(initWithCoder:) toClass:aClass error:error];
			if (error) { return NO; }
		}
		if (!class_getInstanceMethod(aClass, @selector(encodeWithCoder:))) {
			[NSCodingAspect addMethod:@selector(encodeWithCoder:) toClass:aClass error:error];
			if (error) { return NO; }
		}
		//all the ivars need to conform to NSCoding, too
		unsigned int numIvars = 0;
		Ivar * ivars = class_copyIvarList(aClass, &numIvars);
		for(int i = 0; i < numIvars; i++) {
			NSString * type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivars[i])];
			if ([type length] > 3) {
				NSString * class = [type substringWithRange:NSMakeRange(2, [type length]-3)];
				Class ivarClass = NSClassFromString(class);
				[NSCodingAspect addToClass:ivarClass error:error];
			}
		}
	}
	return YES;
}

- (id) initWithCoder:(NSCoder *)decoder {
	if ([super respondsToSelector:@selector(initWithCoder:)] && ![self isKindOfClass:[super class]]) {
		self = [super performSelector:@selector(initWithCoder:) withObject:decoder];
	} else {
		self = [super init];
	}
	if (self == nil) { return nil; }
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	unsigned int numIvars = 0;
	Ivar * ivars = class_copyIvarList([self class], &numIvars);
	for(int i = 0; i < numIvars; i++) {
		@try {
			Ivar thisIvar = ivars[i];
			NSString * key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
			id value = [decoder decodeObjectForKey:key];
			if (value == nil) { value = [NSNumber numberWithFloat:0.0]; }
			[self setValue:value forKey:key];
		} @catch (id exc) {
			continue;
		}
	}
	if (numIvars > 0) { free(ivars); }
	[pool drain];
	return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
	if ([super respondsToSelector:@selector(encodeWithCoder:)] && ![self isKindOfClass:[super class]]) {
		[super performSelector:@selector(encodeWithCoder:) withObject:encoder];
	}
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	unsigned int numIvars = 0;
	Ivar * ivars = class_copyIvarList([self class], &numIvars);
	for (int i = 0; i < numIvars; i++) {
		Ivar thisIvar = ivars[i];
		NSString * key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
		id value = [self valueForKey:key];
		[encoder encodeObject:value forKey:key];
	}
	if (numIvars > 0) { free(ivars); }
	[pool drain];
}

@end

