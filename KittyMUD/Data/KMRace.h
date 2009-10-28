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

@interface KMRace : NSObject <KMDataStartup,KMMenu> {
	NSString* name;
	NSString* abbreviation;
	KMStat* bonuses;
}

+(NSArray*)getAllRaces;

+(KMRace*)getRaceByName:(NSString*)racename;

+(KMRace*)loadRaceWithPath:(NSString*)path;

@property (copy,readwrite) NSString* name;
@property (copy,readwrite) NSString* abbreviation;
@property (retain,readwrite) KMStat* bonuses;

@end
