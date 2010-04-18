//
//  KMClass.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/10/09.
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

#import "KMClass.h"
#import "KMStack.h"
#import "KMCharacter.h"

static KMDataManager* classLoader;
static NSMutableArray* classes;

KMDataManager* KMClass_setUpDataManager(void);

@implementation KMClass
static KMStatLoadType KMClassCustomLoadingContext = KMStatLoadTypeJob;

KMDataManager* KMClass_setUpDataManager() {
	KMDataManager* jl = [[KMDataManager alloc] init];
	[jl registerTag:@"class",@"name",@"name",@"abbr",@"abbreviation",@"tier",@"tier",nil];
	[jl registerTag:@"stattemplate" forKey:@"requirements" forCustomLoading:[KMStat class] withContext:&KMClassCustomLoadingContext];
	return jl;
}

+(void)initData
{
	NSArray* classesToLoad = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[@"$(KMClassSourceDir)" replaceAllVariables] error:NULL];
	
	if(!classesToLoad)
		return;
	
	classes = [[NSMutableArray alloc] init];
	for(NSString* classToLoad in classesToLoad) {
		if(![[classToLoad substringWithRange:NSMakeRange([classToLoad length] - 4, 4)] isEqualToString:@".xml"])
			continue;
		KMClass* klass = [KMClass loadClassWithPath:[[NSString stringWithFormat:@"$(KMClassSourceDir)/%@",classToLoad] replaceAllVariables]];
		OCLog(@"kittymud",info,@"Adding class %@(%@) (Tier: %d) to list of classes.", [klass name], [klass abbreviation], [klass tier]);
		[classes addObject:klass];
	}
}

+(NSArray*)getAllClasses
{
	return (NSArray*)classes;
}

+(KMClass*)getClassByName:(NSString*)classname
{
	NSPredicate* classPred = [NSPredicate predicateWithFormat:@"self.name like[cd] %@ or self.abbreviation like[cd] %@", classname, classname];
	NSArray* classMatches = [classes filteredArrayUsingPredicate:classPred];
	if([classMatches count] > 0)
		return [classMatches objectAtIndex:0];
	else {
		return nil;
	}
}

+(void)addClasses:(NSArray*)_classes {
	if(!classes) {
		classes = [[NSMutableArray alloc] init];
	}
	for(id obj in _classes) {
		if([obj isKindOfClass:[KMClass class]]) {
			[classes addObject:obj];
		}
	}
}

+(KMClass*)loadClassWithPath:(NSString*)path
{
	if(classLoader == nil)
		classLoader = KMClass_setUpDataManager();
	
	KMClass* klass = [[KMClass alloc] init];
	[classLoader loadFromPath:path toObject:&klass];
	return klass;
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
	NSMutableArray* klasses = [[NSMutableArray alloc] init];
	for(KMClass* j in [self getAllClasses]) {
		if([j meetsRequirements:character])
			[klasses addObject:j];
	}
	return klasses;
}

@synthesize name;
@synthesize abbreviation;
@synthesize requirements;
@synthesize tier;
@synthesize specials;
@synthesize powers;

@end
