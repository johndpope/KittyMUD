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

void initializeData() {
	__strong Class* classes;
	int numClasses = objc_getClassList(NULL, 0);
	
	classes = malloc(sizeof(Class) * numClasses);
	objc_getClassList(classes, numClasses);
	for(int i = 0; i < numClasses; i++) {
		@try {
			Class c = classes[i];
			if(class_respondsToSelector(c,@selector(className))) {
				if([[c className] hasPrefix:@"RK"])
					continue;
			}
			if(class_respondsToSelector(c,@selector(conformsToProtocol:))) {
				if([c conformsToProtocol:@protocol(KMDataStartup)]) {
					NSLog(@"Initializing data for %@...", [c className]);
					[c initData];
				}
			}
		}
		@catch (id exc) {
			continue;
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

