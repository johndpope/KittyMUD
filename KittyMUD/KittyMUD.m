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
#import "NSCodingAspect.h"
#import "KMXDFReference.h"

void initializeData(BOOL codingOnly) {
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
				if([[(id)c className] hasPrefix:@"KM"]) {
					NSError* error = [[NSError alloc] init];
					BOOL res = [NSCodingAspect addToClass:c error:&error];
					if(!res) {
						NSLog(@"Error adding NSCoding to class %@, error %@", [(id)c className], [[error userInfo] objectForKey:@"errMsg"]);
					}
				}
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
	if(!codingOnly) {
		for(Class c in classesToInit) {
			NSLog(@"Initializing data for %@...", [(id)c className]);
			[c initData];
		}
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
	initializeData(NO);
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
	initializeData(YES);
	NSLog(@"Starting server on port %d...\n", port);
	NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
	NSTimer* timer = [NSTimer timerWithTimeInterval:0.5 target:[server getConnectionPool] selector:@selector(checkOutputBuffers:) userInfo:nil repeats:YES];
	[runLoop addTimer:timer forMode:NSRunLoopCommonModes];
	while([server isRunning]) { [runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]]; }
	return 0;
}

