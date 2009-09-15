//
//  main.m
//  KittyMUD
//
//  Created by Michael Tindal on 8/21/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMServer.h"
#import "KMColorProcessWriteHook.h"
#import "KMVariableHook.h"
#import "KMMudVariablesExtensions.h"

int main(int argc, char *argv[])
{
	[NSString initializeVariableDictionary];
	[NSString addVariableWithKey:@"Version" andValue:@"`G0.2`x"];
	[NSString addVariableWithKey:@"Name" andValue:@"`MK`m`ci`Ct`wt`Cy`cM`mU`MD $(Version)"];
	[NSString addVariableWithKey:@"BundleDir" andValue:[[NSBundle mainBundle] bundlePath]];
	[NSString addVariableWithKey:@"SaveDir" andValue:@"$(BundleDir)/saves"];
	KMServer* server = [KMServer getDefaultServer];
	NSError* error = [[NSError alloc] init];
	BOOL result = [server initializeServerWithPort:7000 error:&error];
	if (!result) {
		NSLog(@"Error starting server, exiting.");
		return NO;
	}
	KMColorProcessWriteHook* hook = [[KMColorProcessWriteHook alloc] init];
	KMVariableHook* vhook = [[KMVariableHook alloc] init];
	KMWriteHook* colorHook = [[KMWriteHook alloc] initializeWithTarget:hook andSelector:@selector(processHook:)];
	KMWriteHook* variableHook = [[KMWriteHook alloc] initializeWithTarget:vhook andSelector:@selector(processHook:)];
	[[server getConnectionPool] addHook:colorHook];
	[[server getConnectionPool] addHook:variableHook];
	NSLog(@"Starting server on port 7000...\n");
	NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
	NSTimer* timer = [NSTimer timerWithTimeInterval:0.5 target:[server getConnectionPool] selector:@selector(checkOutputBuffers:) userInfo:nil repeats:YES];
	[runLoop addTimer:timer forMode:NSRunLoopCommonModes];
	BOOL shouldBeRunning = YES;
	while(shouldBeRunning) { [runLoop runUntilDate:[NSDate distantFuture]]; }
	return YES;
}
