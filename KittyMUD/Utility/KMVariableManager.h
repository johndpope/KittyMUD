//
//  KMVariableManager.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/16/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMObject.h"

@interface  KMVariableManager  : KMObject {
	NSString* fileName;
	NSMutableDictionary* variables;
}

-(id) init;

-(id) initializeWithConfigFile:(NSString*)configFile;

-(void) loadAllVariables;

-(BOOL) saveAllVariables;

@property (copy) NSString* fileName;
@property (copy) NSMutableDictionary* variables;

@end
