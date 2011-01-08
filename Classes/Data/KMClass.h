//
//  KMClass.h
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
