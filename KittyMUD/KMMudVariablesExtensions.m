//
//  KMMudVariablesExtensions.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/15/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMMudVariablesExtensions.h"
#include <openssl/md5.h>

static NSMutableDictionary* kmMudVariables = nil;

@implementation NSString (KMMudVariablesExtensions)

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
	[kmMudVariables setValue:value forKey:key];
}

-(NSString*) replaceAllVariables
{
	NSString* current = [self copy];
	NSString* (^replaceVariablesHelper)(NSString*) = ^(NSString* input){
		for(NSString* key in [kmMudVariables allKeys]) {
			input = [input stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"$(%@)",key] withString:[kmMudVariables objectForKey:key] options:NSCaseInsensitiveSearch range:NSMakeRange(0,[input length])];
		}
		return input;
	};
	self = replaceVariablesHelper(self);
	while (![self isEqualToString:current]) {
		current = [self copy];
		self = replaceVariablesHelper(self);
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
@end
