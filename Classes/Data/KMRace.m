//
//  KMRace.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/4/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as 
// published by the Free Software Foundation; either version 3 of 
// the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
//

#import "KMRace.h"

static KMDataManager* raceLoader;
static NSMutableArray* races;

@implementation KMRace

static KMStatLoadType KMRaceCustomLoadingContext = KMStatLoadTypeRace;

KMDataManager* kmrace_setUpDataManager(void);

KMDataManager* kmrace_setUpDataManager() {
	KMDataManager* rl = [[KMDataManager alloc] init];
	[rl registerTag:@"race",@"name",@"name",@"abbr",@"abbreviation",nil];
	[rl registerTag:@"stattemplate" forKey:@"bonuses" forCustomLoading:(id<KMDataCustomLoader>)[KMStat class] withContext:&KMRaceCustomLoadingContext];
	return rl;
}

+(void)initData
{
	NSArray* racesToLoad = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[@"$(KMRaceSourceDir)" replaceAllVariables] error:NULL];
	
	if(!racesToLoad)
		return;
	
	races = [[NSMutableArray alloc] init];
	for(NSString* raceToLoad in racesToLoad) {
		if(![[raceToLoad substringWithRange:NSMakeRange([raceToLoad length] - 4, 4)] isEqualToString:@".xml"])
			continue;
		KMRace* race = [KMRace loadRaceWithPath:[[NSString stringWithFormat:@"$(KMRaceSourceDir)/%@",raceToLoad] replaceAllVariables]];
		if([race name]) {
			OCLog(@"kittymud",info,@"Adding race %@(%@) to list of races.", [race name], [race abbreviation]);
			[races addObject:race];
			[[race bonuses] KM_debugPrintTree:0];
		}
	}
}

+(NSArray*)getAllRaces
{
	return (NSArray*)races;
}

+(void)addRaces:(NSArray*)_races {
	if(!races) {
		races = [[NSMutableArray alloc] init];
	}
	for(id obj in _races) {
		if([obj isKindOfClass:[KMRace class]]) {
			[races addObject:obj];
		}
	}
}

+(KMRace*)getRaceByName:(NSString*)racename
{
	NSPredicate* racePred = [NSPredicate predicateWithFormat:@"self.name like[cd] %@ or self.abbreviation like[cd] %@", racename, racename];
	NSArray* raceMatches = [races filteredArrayUsingPredicate:racePred];
	if([raceMatches count] > 0)
		return [raceMatches objectAtIndex:0];
	else {
		return nil;
	}
}

+(KMRace*)loadRaceWithPath:(NSString*)path
{
	if(raceLoader == nil)
		raceLoader = kmrace_setUpDataManager();
	
	KMRace* race = [[KMRace alloc] init];
	[raceLoader loadFromPath:path toObject:&race];
	return race;
}

-(id) init {
	self = [super init];
	if(self) {
		specials = [NSMutableArray array];
		powers = [NSMutableArray array];
	}
	return self;
}

-(NSString*)menuLine
{
	return [[self name] capitalizedString];
}

@synthesize name;
@synthesize abbreviation;
@synthesize bonuses;
@synthesize specials;
@synthesize powers;

-(void)debugPrint {
	OCLog(@"kittymud",info,@"Race name = %@, abbreviation = %@", name, abbreviation);
	[bonuses KM_debugPrintTree:0];
}

@end
