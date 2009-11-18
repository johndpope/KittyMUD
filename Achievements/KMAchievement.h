//
//  KMAchievement.h
//  KittyMUD
//
//  Created by Michael Tindal on 11/17/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XDF/XDF.h>

@interface KMAchievement : NSObject {
	NSNumber* pointValue;
	NSString* name;
	NSString* description;
	XSHNode* earnCriteria;
}

-(id) initWithName:(NSString*)n description:(NSString*)d points:(NSNumber*)p criteria:(XSHNode*)c;

-(void) displayAchievementEarnedMessage:(id)coordinator;

-(void) displayAchievementDetailMessage:(id)coordinator;

@property (retain) NSNumber* pointValue;
@property (retain) NSString* name;
@property (retain) NSString* description;
@property (retain) XSHNode* earnCriteria;

@end
