//
//  KMItemEnhancement.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/17/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMStat.h"
#import "KMObject.h"

typedef enum {
	KMItemEnhancementPrefix,
	KMitemEnhancementSuffix,
	KMItemEnhancementSet,
	KMitemEnhancementUseFunction,
} KMItemEnhancementType;

typedef enum {
	KMItemBonusSet = 1<<1,
	KMItemBonusPercent = 1<<2,
	KMItemBonusMultiply = 1<<3,
	KMItemBonusMultiplyPercent = KMItemBonusPercent | KMItemBonusMultiply,
} KMItemEnhancementBonusType;

@interface  KMItemEnhancement  : KMObject {
	KMItemEnhancementType enhType;
	KMItemEnhancementBonusType bonusType;
	NSString* statToMultiply;
	KMStat* statBonus;
	int socketBonus;
	NSString* useMethod;
	NSString* enhFamily;
	NSString* itemType;
	int enhLevel;
	int minItemLevel;
}

@property (assign) KMItemEnhancementType enhType;
@property (retain) KMStat* statBonus;
@property (copy) NSString* useMethod;
@property (copy) NSString* enhFamily;
@property (assign) int socketBonus;
@property (assign) int enhLevel;
@property (assign) int minItemLevel;
@property (assign) KMItemEnhancementBonusType bonusType;
@property (retain) NSString* statToMultiply;
@property (retain) NSString* itemType;
@end
