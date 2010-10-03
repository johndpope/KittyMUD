//
//  KMPower.h
//  KittyMUD
//
//  Created by Michael Tindal on 1/17/10.
//  Copyright 2010 Michael Tindal. All rights reserved.
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
#import <xi/xi.h>
#import "KMObject.h"
#import "KMEnumFactory.h"

#define KM_POWER_TYPE(XX) \
	XX(KMPowerAttackType,,@"attack") \
	XX(KMPowerFeatureType,,@"feature") \
	XX(KMPowerUtilityType,,@"utility") \

KMDeclareEnum(KM,PowerType,KM_POWER_TYPE);

#define KM_POWER_USAGE(XX) \
	XX(KMPowerAtWill,,@"at-will") \
	XX(KMPowerEncounter,,@"encounter") \
	XX(KMPowerDaily,,@"daily") \

KMDeclareEnum(KM,PowerUsage,KM_POWER_USAGE);

#define KM_POWER_ACTION_TYPE(XX) \
	XX(KMPowerFreeAction,,@"free") \
	XX(KMPowerMinorAction,,@"minor") \
	XX(KMPowerMoveAction,,@"move") \
	XX(KMPowerStandardAction,,@"standard") \
	XX(KMPowerImmediateInterrupt,,@"immediate interrupt") \
	XX(KMPowerImmediateReaction,,@"immediate reaction") \
	XX(KMPowerNoAction,,@"no") \

KMDeclareEnum(KM,PowerActionType,KM_POWER_ACTION_TYPE);

@interface KMPower : KMObject {
	KMPowerType type;
	KMPowerUsage usage;
	NSString* myId;
	NSString* displayName;
	XiNode* definition;
	NSString* command;
	NSArray* defargs;
	NSMutableDictionary* variables;
	KMPowerActionType action;
	NSInteger level;
	BOOL hasSpecialUsage;
	XiNode* usageTest;
	NSArray* keywords;
}

+(KMPower*) createPowerWithRootElement:(NSXMLElement*)root;

-(BOOL) hasKeyword:(NSString*)keyword;

@property (assign) KMPowerType type;
@property (assign) KMPowerUsage usage;
@property (copy) NSString* myId;
@property (copy) NSString* displayName;
@property (retain) XiNode* definition;
@property (assign) NSArray* defargs;
@property (assign) NSMutableDictionary* variables;
@property (assign) KMPowerActionType action;
@property (copy) NSString* command;
@property (assign) NSInteger level;
@property (retain) XiNode* usageTest;
@property (assign) BOOL hasSpecialUsage;
@property (retain) NSArray* keywords;
@end
