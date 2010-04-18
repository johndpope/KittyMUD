//
//  KMDataManager.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/3/09.
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
