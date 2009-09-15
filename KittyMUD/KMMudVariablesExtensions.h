//
//  KMMudVariablesExtensions.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSString (KMMudVariableExtensions)

+(void) initializeVariableDictionary;

+(NSMutableDictionary*)getVariableDictionary;

+(void) addVariableWithKey:(NSString*)key andValue:(NSString*)value;

-(NSString*) replaceAllVariables;

@end
