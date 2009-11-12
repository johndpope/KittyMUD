//
//  KMItemTemplate.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/17/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
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
