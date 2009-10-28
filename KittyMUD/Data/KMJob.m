//
//  KMJob.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/10/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMJob.h"
#import "KMStack.h"
#import "KMCharacter.h"

static KMDataManager* jobLoader;
static NSMutableArray* jobs;

@implementation KMJob
static KMStatLoadType KMJobCustomLoadingContext = KMStatLoadTypeJob;

KMDataManager* kmjob_setUpDataManager() {
	KMDataManager* jl = [[KMDataManager alloc] init];
	[jl registerTag:@"job",@"name",@"name",@"abbr",@"abbreviation",@"tier",@"tier",nil];
	[jl registerTag:@"stattemplate" forKey:@"requirements" forCustomLoading:[KMStat class] withContext:&KMJobCustomLoadingContext];
	return jl;
}

+(void)initData
{
	NSArray* jobsToLoad = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[@"$(KMJobSourceDir)" replaceAllVariables] error:NULL];
	
	if(!jobsToLoad)
		return;
	
	jobs = [[NSMutableArray alloc] init];
	for(NSString* jobToLoad in jobsToLoad) {
		if(![[jobToLoad substringWithRange:NSMakeRange([jobToLoad length] - 4, 4)] isEqualToString:@".xml"])
			continue;
		KMJob* job = [KMJob loadJobWithPath:[[NSString stringWithFormat:@"$(KMJobSourceDir)/%@",jobToLoad] replaceAllVariables]];
		NSLog(@"Adding job %@(%@) (Tier: %d) to list of jobs.", [job name], [job abbreviation], [job tier]);
		[jobs addObject:job];
	}
}

+(NSArray*)getAllJobs
{
	return (NSArray*)jobs;
}

+(KMJob*)getJobByName:(NSString*)jobname
{
	NSPredicate* jobPred = [NSPredicate predicateWithFormat:@"self.name like[cd] %@ or self.abbreviation like[cd] %@", jobname, jobname];
	NSArray* jobMatches = [jobs filteredArrayUsingPredicate:jobPred];
	if([jobMatches count] > 0)
		return [jobMatches objectAtIndex:0];
	else {
		return nil;
	}
}

+(KMJob*)loadJobWithPath:(NSString*)path
{
	if(jobLoader == nil)
		jobLoader = kmjob_setUpDataManager();
	
	KMJob* job = [[KMJob alloc] init];
	[jobLoader loadFromPath:path toObject:&job];
	return job;
}

-(NSString*)menuLine
{
	return [[self name] capitalizedString];
}

-(BOOL) meetsRequirements:(id)character
{
	__block KMStat* stats = [character stats];
	__block BOOL (^meetsRequirementsHelper)(KMStat*) = NULL;
	
	__block BOOL ok = YES;
	meetsRequirementsHelper = ^BOOL(KMStat* stat) {
		for(KMStat* s in [stat getChildren]) {
			KMStack* stack = [[KMStack alloc] init];
			
			[stack push:[s name]];
	
			KMStat* sp = [s parent];
			while( sp != nil ) {
				[stack push:[sp name]];
				sp = [sp parent];
			}
			NSMutableString* full = [[NSMutableString alloc] init];
			while( [stack peek] ) {
				NSString* x = [stack pop];
				if( [x isEqualToString:@"main"] )
					continue;
				[full appendFormat:@"%@::", x];
			}
			[full deleteCharactersInRange:NSMakeRange([full length] - 2,2)];
			
			if(![stats findStatWithPath:full])
				return NO;
			KMStat* child = [stats findStatWithPath:full];
			if([child statvalue] < [s statvalue])
				return NO;
			if([s hasChildren]) {
				ok = meetsRequirementsHelper( s );
				if( !ok )
					return ok;
			}
		}
		
		return ok;
	};
	
	return meetsRequirementsHelper( requirements );
}

+(NSArray*)getAvailableJobs:(id)character {
	NSMutableArray* jobs = [[NSMutableArray alloc] init];
	for(KMJob* j in [self getAllJobs]) {
		if([j meetsRequirements:character])
			[jobs addObject:j];
	}
	return jobs;
}

@synthesize name;
@synthesize abbreviation;
@synthesize requirements;
@synthesize tier;
@end
