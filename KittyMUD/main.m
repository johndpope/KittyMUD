//
//  main.m
//  KittyMUD
//
//  Created by Michael Tindal on 8/21/09.
//  Copyright Gravinity Studios 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMServer.h"
#import "KMColorProcessWriteHook.h"
#import "KMVariableHook.h"
#import "KMMudVariablesExtensions.h"
#import "KMVariableManager.h"

void testRc(id coor) {
	NSLog(@"In test Rc");
	return;
}

int main(int argc, char *argv[])
{
	[NSString initializeVariableDictionary];
	[NSString addVariableWithKey:@"BundleDir" andValue:[[NSBundle mainBundle] bundlePath]];
	KMVariableManager* varManager = [[KMVariableManager alloc] initializeWithConfigFile:[NSString stringWithFormat:@"%@/config/sys.conf",[[NSBundle mainBundle] bundlePath]]];
	KMServer* server = [KMServer getDefaultServer];
	NSError* error = [[NSError alloc] init];
	BOOL result = [server initializeServerWithPort:7000 error:&error];
	if (!result) {
		NSLog(@"Error starting server, exiting.");
		return NO;
	}
	[[server getConnectionPool] addHook:[[KMColorProcessWriteHook alloc] init]];
	[[server getConnectionPool] addHook:[[KMVariableHook alloc] init]];
	[[server getConnectionPool] setReadCallback:^(id coordinator){
		KMConnectionPool* pool = [[KMServer getDefaultServer] getConnectionPool];
		if([[coordinator getInputBuffer] isEqualToString:@"testwriteall"])
			[pool writeToAllConnections:@"Test Write All (whitespace trim)"];
		if([[coordinator getInputBuffer] isEqualToString:@"testshutdown"]) {
			[coordinator sendMessage:@"Shutdown initiated..."];
			[[KMServer getDefaultServer] shutdown];
		} }];
	NSLog(@"Starting server on port 7000...\n");
	NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
	NSTimer* timer = [NSTimer timerWithTimeInterval:0.5 target:[server getConnectionPool] selector:@selector(checkOutputBuffers:) userInfo:nil repeats:YES];
	[runLoop addTimer:timer forMode:NSRunLoopCommonModes];
	while([server isRunning]) { [runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]]; }
	return YES;
}
