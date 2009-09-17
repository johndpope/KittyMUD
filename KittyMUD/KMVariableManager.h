//
//  KMVariableManager.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/16/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KMVariableManager : NSObject {
	NSString* fileName;
	NSMutableDictionary* variables;
}

-(id) init;

-(id) initializeWithConfigFile:(NSString*)configFile;

-(void) loadAllVariables;

-(BOOL) saveAllVariables;

@property NSString* fileName;
@property NSMutableDictionary* variables;

@end
