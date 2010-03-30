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

typedef enum {
	KMPowerAttackType,
	KMPowerFeatureType,
	KMPowerUtilityType
} KMPowerType;

typedef enum {
	KMPowerAtWill,
	KMPowerEncounter,
	KMPowerDaily,
	KMPowerSpecial
} KMPowerUsage;

typedef enum {
	KMPowerFreeAction,
	KMPowerMinorAction,
	KMPowerMoveAction,
	KMPowerStandardAction,
	KMPowerImmediateInterrupt,
	KMPowerImmediateReaction,
	KMPowerNoAction
} KMPowerActionType;

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
	ECSNode* usageTest;
}

+(KMPower*) createPowerWithRootElement:(NSXMLElement*)root;

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
@end
