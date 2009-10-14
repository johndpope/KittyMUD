//
//  KMJob.h
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

@interface KMJob : NSObject <KMDataStartup,KMMenu> {
	NSString* name;
	NSString* abbreviation;
	int tier;
	KMStat* requirements;
}

+(NSArray*)getAllJobs;

+(KMJob*)getJobByName:(NSString*)jobname;

+(KMJob*)loadJobWithPath:(NSString*)path;

-(BOOL) meetsRequirements:(id)character;

+(NSArray*)getAvailableJobs:(id)character;

@property (copy,readwrite) NSString* name;
@property (copy,readwrite) NSString* abbreviation;
@property (retain,readwrite) KMStat* requirements;
@property (assign,readwrite) int tier;
@end
