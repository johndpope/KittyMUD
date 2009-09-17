//
//  KMMudVariablesExtensions.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/15/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (KMMudVariableExtensions)

+(void) initializeVariableDictionary;

+(NSMutableDictionary*)getVariableDictionary;

+(void) addVariableWithKey:(NSString*)key andValue:(NSString*)value;

-(NSString*) replaceAllVariables;

@end
