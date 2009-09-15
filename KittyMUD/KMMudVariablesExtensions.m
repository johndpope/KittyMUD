//
//  KMMudVariablesExtensions.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/15/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMMudVariablesExtensions.h"

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
			input = [input stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"$(%@)",key] withString:[kmMudVariables objectForKey:key]];
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

@end
