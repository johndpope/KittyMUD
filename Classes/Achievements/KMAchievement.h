//
//  KMAchievement.h
//  KittyMUD
//
//  Created by Michael Tindal on 11/17/09.
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
	@param coordinator: The coordinator representing the connection to send the earn message to.
*/
-(void) displayAchievementHasBeenEarnedMessageTo:(id)coordinator;

/*! @method displayAchievementDetailMessageTo:
    @abstract Sends detail about an achievement to a connection.
    @discussion Tells this achievement to send detail about itself to a connection.
    @param coordinator: The coordinator representing the connection to send the message to.
*/
-(void) displayAchievementDetailMessageTo:(id)coordinator;

@property (retain) NSNumber* pointValue;
@property (retain) NSString* name;
@property (retain) NSString* description;
@property (retain) ECSNode* earnCriteria;

@end
