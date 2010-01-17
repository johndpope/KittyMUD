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
	KMPowerDaily
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
	int defargs;
	NSArray* variables;
	KMPowerActionType action;
}

+(KMPower*) createPowerWithRootElement:(NSXMLElement*)root;

@property (assign) KMPowerType type;
@property (assign) KMPowerUsage usage;
@property (copy) NSString* myId;
@property (copy) NSString* displayName;
@property (retain) ECSNode* definition;
@property (assign) int defargs;
@property (assign) NSArray* variables;
@property (assign) KMPowerActionType action;
@property (copy) NSString* command;

@end