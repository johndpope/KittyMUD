//
//  KMItemEnhancement.h
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
