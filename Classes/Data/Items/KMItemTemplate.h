//
//  KMItemTemplate.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/17/09.
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
#import "KMObject.h"

typedef enum {
	KMItemRarityTrash,
	KMItemRarityCommon,
	KMItemRarityUncommon,
	KMItemRarityRare,
	KMItemRarityEpic,
	KMItemRarityRelic,
	KMItemRarityArtifact,
} KMItemRarity;

@interface  KMItemTemplate  : KMObject {
	KMItemRarity rarity;
	NSString* itemID;
	NSString* itemType;
	NSString* itemFamily;
	int minPrefixSuffix;
	int maxPrefixSuffix;
	NSArray* setEnhancements;
	int itemLevel;
	KMStat* stats;
	int minSockets;
	int maxSockets;
}

@property (assign) KMItemRarity rarity;
@property (copy) NSString* itemID;
@property (copy) NSString* itemType;
@property (assign) int minPrefixSuffix;
@property (assign) int maxPrefixSuffix;
@property (copy) NSArray* setEnhancements;
@property (assign) int itemLevel;
@property (retain) KMStat* stats;
@property (assign) int minSockets;
@property (assign) int maxSockets;
@property (copy) NSString* itemFamily;
@end
