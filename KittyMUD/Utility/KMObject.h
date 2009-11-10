//
//  KMObject.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/31/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface  KMObject  : NSObject {
	NSMutableDictionary* properties;
	NSMutableArray* flagbase;
	NSMutableDictionary* flags;
	NSMutableDictionary* flagreasons;
	unsigned int currentbitpower;
}

-(BOOL) isFlagSet:(NSString*)flagName;

-(void) setFlag:(NSString*)flagName;

-(void) setFlag:(NSString *)flagName reason:(NSString*)reason;

-(NSString*) reasonForFlag:(NSString *)flagName;

-(void) clearFlag:(NSString*)flagName;

-(void) debugPrintFlagStatus:(id)coordinator;

@property (retain,readonly,getter=getProperties) NSMutableDictionary* properties;

@end
