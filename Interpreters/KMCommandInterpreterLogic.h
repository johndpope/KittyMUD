//
//  KMCommandInterpreterLogic.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/7/09.
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

#define CHEDC(name) -(void) commandHelp##name:(id)interpreter

#define CHELP(name,shorttext,longtextname) -(void) commandHelp##name:(id)interpreter { \
	[interpreter registerCommandHelp:@#name usingShortText:shorttext withLongTextFile:longtextname]; \
}

#define CDECL(name) -(void) commandSetup##name:(id)interpreter; \
\
	-(void) command##name:(id)coordinator

#define CIMPL(name,fullselectorname,optionalArgumentIndices,aliases,flags,level) -(void) commandSetup##name:(id)interpreter { \
	[interpreter registerCommand:self selector:@selector(command##fullselectorname) withName:@#name andOptionalArguments:[(id)optionalArgumentIndices componentsSeparatedByString:@","] andAliases:[(id)aliases componentsSeparatedByString:@","] \
	andFlags:[(id)flags componentsSeparatedByString:@","] withMinimumLevel:level]; \
} \
\
-(void) command##name:(id)coordinator

#define CMD(name) command##name:coordinator
#define OPT(name) optArgs##name

@protocol KMCommandInterpreterLogic <NSObject>

-(id) initializeWithCommandInterpreter:(id)cmdInterpreter;

-(void) displayHelpToCoordinator:(id)coordinator;

-(void) repeatCommandsToCoordinator:(id)coordinator;

-(BOOL) isRepeating;

@end
