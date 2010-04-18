//
//  KMSpecial.m
//  KittyMUD
//
//  Created by Michael Tindal on 12/5/09.
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

#import "KMSpecial.h"
#import "KMConnectionCoordinator.h"

@implementation KMSpecial

-(id) initWithType:(KMSpecialType)myType identifier:(NSString*)iden displayName:(NSString*)dname andAction:(ECSNode*)act {
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
	} else if([typeName isEqualToString:@"class"]) {
		type = KMClassSpecial;
	}
	NSXMLElement* idElem = [[root elementsForName:@"id"] objectAtIndex:0];
	iden = [idElem stringValue];
	NSXMLElement* name = [[root elementsForName:@"name"] objectAtIndex:0];
	displayName = [name stringValue];
	NSXMLElement* act = [[root elementsForName:@"action"] objectAtIndex:0];
	NSXMLNode* actAttribute = [act attributeForName:@"act"];
	NSString* actText = [actAttribute stringValue];
	if([actText isEqualToString:@":[text]"]) {
		actText = [act stringValue];
	}
	action = [ECSNode createNodeFromSource:actText];
	return [[KMSpecial alloc] initWithType:type identifier:iden displayName:displayName andAction:action];
}

-(id) executeSpecial:(KMConnectionCoordinator*)coordinator {
}
@synthesize type;
@synthesize myId;
@synthesize displayName;
@synthesize action;
@end
