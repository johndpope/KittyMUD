//
//  KittyMudStringExtensions.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/15/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KittyMudStringExtensions.h"
#import "KMColorProcessWriteHook.h"
#import <openssl/md5.h>
#import <RegexKit/RegexKit.h>

static NSMutableDictionary* kmMudVariables = nil;

@implementation NSString (KittyMudStringExtensions)

+(void) initializeVariableDictionary
{
	if(!kmMudVariables)
		kmMudVariables = [[NSMutableDictionary alloc] init];
}

+(NSMutableDictionary*)getVariableDictionary
{
	return kmMudVariables;
}

+(void) addVariableWithKey:(NSString*)key andValue:(NSString*)value
{
	[kmMudVariables setValue:value forKey:[key lowercaseString]];
}

-(NSString*) replaceAllVariables
{
	return [self replaceAllVariablesWithDictionary:kmMudVariables];
}

-(NSString*) replaceAllVariablesWithDictionary:(NSDictionary*)dictionary
{
	NSMutableDictionary* myDictionary = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
	if(dictionary != kmMudVariables) {
		for(NSString* key in [myDictionary allKeys])
		{
			if(![[key lowercaseString] isEqualToString:key])
				[myDictionary setObject:[dictionary objectForKey:key] forKey:[key lowercaseString]];
		}
	}
		
	RKRegex* regex = [[RKRegex alloc] initWithRegexString:@"\\$\\((?<varname>\\w+)\\)" options:RKCompileNoOptions];
	while([regex matchesCharacters:[self cStringUsingEncoding:NSASCIIStringEncoding] length:[self length] inRange:NSMakeRange(0, [self length]) options:RKMatchNoOptions])
	{
		NSRange captureRange = [regex rangeForCharacters:[self cStringUsingEncoding:NSASCIIStringEncoding] 
												   length:[self length] 
												 inRange:NSMakeRange(0, [self length]) 
											 captureIndex:[regex captureIndexForCaptureName:@"varname"]
												 options:RKMatchNoOptions];
		NSString* match = [[self substringWithRange:captureRange] lowercaseString];
		NSString* replaceString = [myDictionary objectForKey:match] != nil ? [myDictionary objectForKey:match] : [kmMudVariables objectForKey:match] ? [kmMudVariables objectForKey:match] : nil;
		if(replaceString != nil)
			self = [self stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"$(%@)",match] withString:replaceString options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self length])];
	}
	return self;
}

-(NSString*)MD5
{
	NSData *data = [self dataUsingEncoding:NSASCIIStringEncoding];
	unsigned char *digest = MD5([data bytes], [data length], NULL);
	NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
				   digest[0], digest[1], 
				   digest[2], digest[3],
				   digest[4], digest[5],
				   digest[6], digest[7],
				   digest[8], digest[9],
				   digest[10], digest[11],
				   digest[12], digest[13],
				   digest[14], digest[15]];
	
	return s;
}

-(NSString*)getSpacing {
	__block KMColorProcessWriteHook* hook = [[KMColorProcessWriteHook alloc] init];
	
	NSString* (^getStringSpacing)(NSString*) = ^NSString*(NSString* string) {
		NSMutableString* spacing = [[NSMutableString alloc] init];
		NSString* clrString = [hook processHook:string replace:NO];
		int i = [clrString length];
		while(i++ < 79) {
			[spacing appendString:@" "];
		}
		return (NSString*)spacing;
	};

	return getStringSpacing(self);
}

-(NSString*) stringValue {
	return self;
}

@end
