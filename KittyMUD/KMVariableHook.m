//
//  KMVariableHook.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/15/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMVariableHook.h"
#import "KMMudVariablesExtensions.h"

@implementation KMVariableHook

-(NSString*) processHook:(NSString*)input
{
	return [input replaceAllVariables];
}
@end
