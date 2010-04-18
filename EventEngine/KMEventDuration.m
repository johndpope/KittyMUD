//
//  KMEventDuration.m
//  KittyMUD
//
//  Created by Michael Tindal on 1/29/10.
//  Copyright 2010 Michael Tindal. All rights reserved.
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

#import "KMEventDuration.h"


@implementation KMEventDuration

+(KMEventDuration*) untilEndOfNextTurn {
}

+(KMEventDuration*) once {
}

+(KMEventDuration*) untilNextAttackRollAgainstTarget:(id)t{
}

+(KMEventDuration*) untilEndOfNextTurnForCharacter:(KMCharacter*)c{
}

+(KMEventDuration*) untilNextAttackRoll{
}

+(KMEventDuration*) permanent{
}

+(KMEventDuration*) untilAttackIsFinished{
}

+(KMEventDuration*) untilLevelUp{
}

@end
