#import <Foundation/Foundation.h>
#import <RegexKit/RegexKit.h>
#import <objc/runtime.h>
#import "KMServer.h"
#import "KMColorProcessWriteHook.h"
#import "KMVariableHook.h"
#import "KittyMudStringExtensions.h"
#import "KMVariableManager.h"
#import "KMStat.h"
#import "KMRace.h"
#import "KMDataStartup.h"
#import "KMStatAllocationLogic.h"
#import "KMCommandInterpreter.h"
#import "KMRoom.h"

@interface NSCodingAspect : NSObject <NSCoding>
+(void) addMethod:(SEL)aSelector toClass:(Class)aClass error:(NSError **)error;

+(void) addToClass:(Class)aClass error:(NSError **)error;
@end

@implementation NSCodingAspect

+ (void) addMethod:(SEL)aSelector toClass:(Class)aClass error:(NSError **)error {
	IMP implementation = class_getMethodImplementation([self class], aSelector);
	Method method = class_getInstanceMethod([self class], aSelector);
	BOOL worked = class_addMethod(aClass, aSelector, implementation, method_getTypeEncoding(method));
	if (!worked) {
		*error = [NSError errorWithDomain:NSStringFromClass(aClass) 
									 code:0 
								 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Error adding method: %@", 
																			  NSStringFromSelector(aSelector)] 
																	  forKey:@"errMsg"]];
	} else {
		error = nil;
	}
}

+ (void) addToClass:(Class)aClass error:(NSError **)error {
	Protocol * codingProtocol = objc_getProtocol("NSCoding");
	BOOL classConforms = class_conformsToProtocol(aClass, codingProtocol);
	NSString * className = NSStringFromClass(aClass);
	
	if (!classConforms) {
		class_addProtocol(aClass, codingProtocol);
		
		if (!class_getInstanceMethod(aClass, @selector(initWithCoder:))) {
			[NSCodingAspect addMethod:@selector(initWithCoder:) toClass:aClass error:error];
			if (error) { return; }
		}
		if (!class_getInstanceMethod(aClass, @selector(encodeWithCoder:))) {
			[NSCodingAspect addMethod:@selector(encodeWithCoder:) toClass:aClass error:error];
			if (error) { return; }
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
		Ivar thisIvar = ivars[i];
		NSString * key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
		id value = [decoder decodeObjectForKey:key];
		if (value == nil) { value = [NSNumber numberWithFloat:0.0]; }
		[self setValue:value forKey:key];
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

void initializeData() {
	__strong Class* classes;
	int numClasses = objc_getClassList(NULL, 0);
	
	classes = malloc(sizeof(Class) * numClasses);
	objc_getClassList(classes, numClasses);
	NSMutableArray* classesToInit = [[NSMutableArray alloc] init];
	NSLog(@"Adding NSCoding support to KittyMUD classes...");
	for(int i = 0; i < numClasses; i++) {
		@try {
			Class c = classes[i];
			if(class_respondsToSelector(c,@selector(className))) {
				if([[(id)c className] hasPrefix:@"RK"])
					continue;
				if([[(id)c className] hasPrefix:@"KM"])
					[NSCodingAspect addToClass:c error:NULL];
			}
			if(class_respondsToSelector(c,@selector(conformsToProtocol:))) {
				if([c conformsToProtocol:@protocol(KMDataStartup)]) {
					[classesToInit addObject:c];
				}
			}
		}
		@catch (id exc) {
			continue;
		}
	}
	for(Class c in classesToInit) {
		NSLog(@"Initializing data for %@...", [(id)c className]);
		[c initData];
	}
}

int main(int argc, char *argv[])
{
	BOOL softreboot = NO;
	NSString* greeting;
	int port = 7000;
	if(argc > 1 && !strcmp(argv[1], "softreboot"))
		softreboot = YES;
	if(argc > 1 && !softreboot) {
		for(int i = 0; i < argc; i++) {
			if(!strcmp(argv[i], "port") && argc > i + 1) {
				port = [[[NSString alloc] initWithCString:argv[i+1]] intValue];
			}
		}
	}
	[NSString initializeVariableDictionary];
	[NSString addVariableWithKey:@"BundleDir" andValue:[[NSBundle mainBundle] bundlePath]];
	KMVariableManager* varManager = [[KMVariableManager alloc] initializeWithConfigFile:[NSString stringWithFormat:@"%@/config/sys.conf",[[NSBundle mainBundle] bundlePath]]];
	KMServer* server = [KMServer getDefaultServer];
	NSError* error = [[NSError alloc] init];
	initializeData();
	if(softreboot)
		[server softRebootRecovery:[[[NSString alloc] initWithCString:argv[2]] intValue]];
	else {
		BOOL result = [server initializeServerWithPort:port error:&error];
		if (!result) {
			NSLog(@"Error starting server, exiting.");
			return NO;
		}
	}

	[[server getConnectionPool] addHook:[[KMColorProcessWriteHook alloc] init]];
	[[server getConnectionPool] addHook:[[KMVariableHook alloc] init]];
	[[server getConnectionPool] setReadCallback:^(id coordinator){
		[[coordinator interpreter] interpret:coordinator];
	}];
	NSLog(@"Starting server on port %d...\n", port);
	NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
	NSTimer* timer = [NSTimer timerWithTimeInterval:0.5 target:[server getConnectionPool] selector:@selector(checkOutputBuffers:) userInfo:nil repeats:YES];
	[runLoop addTimer:timer forMode:NSRunLoopCommonModes];
	while([server isRunning]) { [runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]]; }
	return 0;
}

