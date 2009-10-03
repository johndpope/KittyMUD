//
//  KMDataManager.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/3/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMStat.h"

@interface KMDataManager : NSObject {
	NSMutableDictionary* tagReferences;
	NSMutableDictionary* attributeReferences;
	BOOL loadStats;
	NSString* statKey;
	KMStatLoadType statLoadType;
}

-(id)init;

-(void)registerTag:(NSString*)tag forKey:(NSString*)key;

-(void)registerTag:(NSString*)tag,...;

-(void)loadFromPath:(NSString*)path toObject:(id*)object;

@property (copy) NSString* statKey;

@property (assign) BOOL loadStats;

@property (assign) KMStatLoadType statLoadType;
@end
