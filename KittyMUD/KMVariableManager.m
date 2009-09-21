//
//  KMVariableManager.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/16/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMVariableManager.h"
#import "KittyMudStringExtensions.h"

@implementation KMVariableManager

-(id) init
{
	self = [super init];
	if(self) {
		variables = [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(id) initializeWithConfigFile:(NSString*)configFile
{
	self = [self init];
	if(self) {
		fileName = configFile;
		[self loadAllVariables];
	}
	return self;
}

-(void) loadAllVariables
{
	NSLog(@"Reading configuration file %@...", fileName);
	NSFileHandle* configFile = [NSFileHandle fileHandleForReadingAtPath:fileName];
	if(configFile != nil) {
		NSData* rawcontents = [configFile readDataToEndOfFile];
		NSString* contents = [[NSString alloc] initWithData:rawcontents encoding:NSASCIIStringEncoding];
		NSArray* lines = [contents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		for(NSString* line in lines) {
			if([line length] <= 0)
				break;
			NSArray* parts = [line componentsSeparatedByString:@"="];
			if([line characterAtIndex:0] == '#' || [parts count] < 2)
				continue;
			NSString* name = [parts objectAtIndex:0];
			NSString* value = [parts objectAtIndex:1];
			if([value characterAtIndex:([value length] - 1)] == ';') {
				value = [value substringToIndex:([value length] - 1)];
			}
			[NSString addVariableWithKey:name andValue:value];
			[variables setObject:value forKey:name];
			NSLog(@"Set variable $(%@) to value %@.", name, value);
		}
	}
}

-(BOOL) saveAllVariables
{
	NSFileHandle* configFile = [NSFileHandle fileHandleForWritingAtPath:fileName];
	for(NSString* key in [variables allKeys]) {
		NSString* var = [NSString stringWithFormat:@"%@=%@;\n",key,[variables objectForKey:key]];
		[configFile writeData:[var dataUsingEncoding:NSASCIIStringEncoding]];
	}
}

@synthesize fileName;
@synthesize variables;

@end
