//
//  NSString+KMAdditions.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/15/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (KMAdditions)

+(void) initializeVariableDictionary;

+(NSMutableDictionary*)getVariableDictionary;

+(void) addVariableWithKey:(NSString*)key andValue:(NSString*)value;

-(NSString*) replaceAllVariables;

-(NSString*) replaceAllVariablesWithDictionary:(NSDictionary*)dictionary;

-(NSString*) getSpacing;

-(NSString*) MD5;

-(NSString*) stringValue;

-(NSString*) initWithFormat:(NSString*)format andArray:(NSArray*)array;
@end
