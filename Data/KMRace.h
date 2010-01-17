//
//  KMRace.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/4/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMDataManager.h"
#import "KMStat.h"
#import "KMDataStartup.h"
#import "KMMenu.h"
#import "KMObject.h"
#import "KMPower.h"

@interface  KMRace  : KMObject <KMDataStartup,KMMenu> {
	NSString* name;
	NSString* abbreviation;
	KMStat* bonuses;
	NSMutableArray* specials;
	NSMutableArray* powers;
}

+(NSArray*)getAllRaces;

+(void)addRaces:(NSArray*)_races;

+(KMRace*)getRaceByName:(NSString*)racename;

+(KMRace*)loadRaceWithPath:(NSString*)path;

@property (copy,readwrite) NSString* name;
@property (copy,readwrite) NSString* abbreviation;
@property (retain,readwrite) KMStat* bonuses;
@property (retain,readonly) NSMutableArray* specials;
@property (retain,readonly) NSMutableArray* powers;

@end
