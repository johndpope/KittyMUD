//
//  main.m
//  KittyMUD
//
//  Created by Michael Tindal on 8/21/09.
//  Copyright Gravinity Studios 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMServer.h"
#import "KMColorProcessWriteHook.h"
#import "KMVariableHook.h"
#import "KMMudVariablesExtensions.h"
#import "KMVariableManager.h"

int main(int argc, char *argv[])
{
	BOOL softreboot = NO;
	if(argc > 1 && !strcmp(argv[1], "softreboot"))
		softreboot = YES;
	[NSString initializeVariableDictionary];
	[NSString addVariableWithKey:@"BundleDir" andValue:[[NSBundle mainBundle] bundlePath]];
	KMVariableManager* varManager = [[KMVariableManager alloc] initializeWithConfigFile:[NSString stringWithFormat:@"%@/config/sys.conf",[[NSBundle mainBundle] bundlePath]]];
	KMServer* server = [KMServer getDefaultServer];
	NSError* error = [[NSError alloc] init];
	if(softreboot)
		[server softRebootRecovery:[[[NSString alloc] initWithCString:argv[2]] intValue]];
	else {
		BOOL result = [server initializeServerWithPort:7000 error:&error];
		if (!result) {
			NSLog(@"Error starting server, exiting.");
			return NO;
		}
	}
	[[server getConnectionPool] addHook:[[KMColorProcessWriteHook alloc] init]];
	[[server getConnectionPool] addHook:[[KMVariableHook alloc] init]];
	[[server getConnectionPool] setReadCallback:^(id coordinator){
		if([[coordinator getInputBuffer] isEqualToString:@"softreboot"])
			[server softReboot];
		else {
			NSLog(@"%@", [coordinator getInputBuffer]);
		}
	}];
	NSLog(@"Starting server on port 7000...\n");
	NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
	NSTimer* timer = [NSTimer timerWithTimeInterval:0.5 target:[server getConnectionPool] selector:@selector(checkOutputBuffers:) userInfo:nil repeats:YES];
	[runLoop addTimer:timer forMode:NSRunLoopCommonModes];
	while([server isRunning]) { [runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]]; }
	return YES;
}
