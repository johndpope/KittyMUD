//
//  KMClass.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/10/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMDataStartup.h"
#import "KMDataManager.h"
#import "KMMenu.h"
#import "KMStat.h"
#import "KMObject.h"
#import "KMPower.h"

@interface  KMClass  : KMObject <KMDataStartup,KMMenu> {
	NSString* name;
	NSString* abbreviation;
	int tier;
	KMStat* requirements;
	NSMutableArray* specials;
	NSMutableArray* powers;
}

+(NSArray*)getAllClasses;

+(void)addClasses:(NSArray*)_classes;

+(KMClass*)getClassByName:(NSString*)klassname;

+(KMClass*)loadClassWithPath:(NSString*)path;

-(BOOL) meetsRequirements:(id)character;

+(NSArray*)getAvailableJobs:(id)character;

@property (copy,readwrite) NSString* name;
@property (copy,readwrite) NSString* abbreviation;
@property (retain,readwrite) KMStat* requirements;
@property (assign,readwrite) int tier;
@property (retain,readonly) NSMutableArray* specials;
@property (retain,readonly) NSMutableArray* powers;

@end
