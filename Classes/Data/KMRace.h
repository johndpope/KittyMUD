//
//  KMRace.h
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
