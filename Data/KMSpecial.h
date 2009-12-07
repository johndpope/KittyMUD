//
//  KMSpecial.h
//  KittyMUD
//
//  Created by Michael Tindal on 12/5/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XSHRuntime/XSHRuntime.h>

typedef enum {
	KMRacialSpecial,
	KMClassSpecial,
} KMSpecialType;

@interface KMSpecial : NSObject {
	KMSpecialType type;
	NSString* myId;
	NSString* displayName;
	XSHNode* action;
}

-(id) initWithType:(KMSpecialType)myType identifier:(NSString*)iden displayName:(NSString*)dname andAction:(XSHNode*)act;

+(KMSpecial*) createSpecialWithRootElement:(NSXMLElement*)root;

@property (assign) KMSpecialType type;
@property (copy) NSString* myId;
@property (copy) NSString* displayName;
@property (retain) XSHNode* action;
@end
