//
//  KMSpecial.h
//  KittyMUD
//
//  Created by Michael Tindal on 12/5/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ECScript/ECScript.h>

typedef enum {
	KMRacialSpecial,
	KMClassSpecial,
} KMSpecialType;

@interface KMSpecial : NSObject {
	KMSpecialType type;
	NSString* myId;
	NSString* displayName;
	NSString* action;
}

-(id) initWithType:(KMSpecialType)myType identifier:(NSString*)iden displayName:(NSString*)dname andAction:(NSString*)act;

+(KMSpecial*) createSpecialWithRootElement:(NSXMLElement*)root;

@property (assign) KMSpecialType type;
@property (copy) NSString* myId;
@property (copy) NSString* displayName;
@property (copy) NSString* action;
@end
