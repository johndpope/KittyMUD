//
//  KMPower.h
//  KittyMUD
//
//  Created by Michael Tindal on 1/17/10.
//  Copyright 2010 Michael Tindal. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ECScript/ECScript.h>
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
	ECSNode* definition;
	NSString* command;
	NSArray* defargs;
	NSMutableDictionary* variables;
	KMPowerActionType action;
	NSInteger level;
	BOOL hasSpecialUsage;
	ECSNode* usageTest;
	NSArray* keywords;
}

+(KMPower*) createPowerWithRootElement:(NSXMLElement*)root;

-(BOOL) hasKeyword:(NSString*)keyword;

@property (assign) KMPowerType type;
@property (assign) KMPowerUsage usage;
@property (copy) NSString* myId;
@property (copy) NSString* displayName;
@property (retain) ECSNode* definition;
@property (assign) NSArray* defargs;
@property (assign) NSMutableDictionary* variables;
@property (assign) KMPowerActionType action;
@property (copy) NSString* command;
@property (assign) NSInteger level;
@property (retain) ECSNode* usageTest;
@property (assign) BOOL hasSpecialUsage;
@property (retain) NSArray* keywords;
@end
