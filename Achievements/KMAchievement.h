//
//  KMAchievement.h
//  KittyMUD
//
//  Created by Michael Tindal on 11/17/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ECScript/ECScript.h>

/*! @class KMAchievement
	@abstract Represents an achievement in a KittyMUD game.
	@discussion A KMAchievement object represents a concrete set of criteria, represented
	as something a character can earn, within a KittyMUD game.
*/
@interface KMAchievement : NSObject {
	NSNumber* pointValue;
	NSString* name;
	NSString* description;
	ECSNode* earnCriteria;
}

/*! @method initWithName:description:points:criteria:
	@abstract Initializes a new KMAchievement object.
	@discussion Initializes a new KMAchievement with the given name, description, point value, and earn critera.
	@param aName The name of the achievement.
	@param aDescription The description for the achievement.
	@param thePointValue A NSNumber representing an int value of the amount of points this achievement is worth.
	@param theNode: An ECSNode representing the earn criteria for earning this achievement.
	@result The newly initialized achievement or nil if an error occured.
 */
-(id) initWithName:(NSString*)aName description:(NSString*)aDescription points:(NSNumber*)thePointValue criteria:(ECSNode*)theNode;

/*! @method displayAchievementHasBeenEarnedMessageTo:
	@abstract Sends the achievement earned message.
	@discussion Causes this achievement to send a message to the given coordinator letting it know it earned this achievement.
	@param coordinator 
*/
-(void) displayAchievementHasBeenEarnedMessageTo:(id)coordinator;

-(void) displayAchievementDetailMessageTo:(id)coordinator;

@property (retain) NSNumber* pointValue;
@property (retain) NSString* name;
@property (retain) NSString* description;
@property (retain) ECSNode* earnCriteria;

@end
