//
//  KMDataManager.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/3/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMStat.h"
#import "NSString+KMAdditions.h"
#import "KMDataStartup.h"
#import "KMObject.h"

@interface  KMDataManager  : KMObject {
	NSMutableDictionary* tagReferences;
	NSMutableDictionary* subtagReferences;
	NSMutableDictionary* attributeReferences;
	NSMutableDictionary* customLoaders;
}

-(id)init;

-(void)registerTag:(NSString*)tag forKey:(NSString*)key;

-(void)registerTag:(NSString*)tag,...;

-(void) registerTag:(NSString*)tag forKey:(NSString*)key forCustomLoading:(id<KMDataCustomLoader>)loader withContext:(void*)context;

-(void)loadFromPath:(NSString*)path toObject:(id*)object;

@property (retain) NSMutableDictionary* tagReferences;
@property (retain) NSMutableDictionary* subtagReferences;
@property (retain) NSMutableDictionary* attributeReferences;
@property (retain) NSMutableDictionary* customLoaders;
@end