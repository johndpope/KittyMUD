//
//  KMSpecial.m
//  KittyMUD
//
//  Created by Michael Tindal on 12/5/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//

#import "KMSpecial.h"
#import "KMConnectionCoordinator.h"

@implementation KMSpecial

-(id) initWithType:(KMSpecialType)myType identifier:(NSString*)iden displayName:(NSString*)dname andAction:(XSHNode*)act {
	self = [super init];
	if(self) {
		type = myType;
		myId = [iden copy];
		displayName = [dname copy];
		action = act;
	}
	return self;
}

+(KMSpecial*) createSpecialWithRootElement:(NSXMLElement*)root {
	id action,displayName,iden;
	KMSpecialType type;
	NSXMLNode* typeAttribute = [root attributeForName:@"type"];
	NSString* typeName = [typeAttribute stringValue];
	type = KMRacialSpecial;
	if([typeName isEqualToString:@"racial"]) {
		type = KMRacialSpecial;
	}
	NSXMLElement* idElem = [[root elementsForName:@"id"] objectAtIndex:0];
	iden = [idElem stringValue];
	NSXMLElement* name = [[root elementsForName:@"name"] objectAtIndex:0];
	displayName = [name stringValue];
	NSXMLElement* act = [[root elementsForName:@"action"] objectAtIndex:0];
	NSXMLNode* actAttribute = [act attributeForName:@"act"];
	action = [XSHNode createNodeFromSource:[actAttribute stringValue]];
	return [[KMSpecial alloc] initWithType:type identifier:iden displayName:displayName andAction:action];
}

-(id) executeSpecial:(KMConnectionCoordinator*)coordinator {
}
@synthesize type;
@synthesize myId;
@synthesize displayName;
@synthesize action;
@end
