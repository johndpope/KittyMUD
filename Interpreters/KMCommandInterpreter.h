//
//  KMCommandInterpreter.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/6/09.
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
#import "KMInterpreter.h"
#import "KMBasicInterpreter.h"
#import "KMCommandInterpreterLogic.h"
#import "KMConnectionCoordinator.h"
#import "KMCommandInfo.h"
#import "KMObject.h"

@interface  KMCommandInterpreter  : KMBasicInterpreter {
	NSMutableArray* commands;
	NSMutableDictionary* logics;
	id<KMCommandInterpreterLogic> defaultTarget;
	NSMutableArray* myLogics;
}

-(id) init;

-(void) registerLogic:(Class)clogic;

-(void) registerLogic:(Class)clogic asDefaultTarget:(BOOL)dt;

-(void)registerCommand:(id)target selector:(SEL)commandSelector withName:(NSString*)name andOptionalArguments:(NSArray*)optional andAliases:(NSArray*)aliases andFlags:(NSArray*)cflags withMinimumLevel:(int)level;

-(void) interpret:(id)coordinator;

-(void) registerCommandHelp:(NSString*)name usingShortText:(NSString*)shorttext withLongTextFile:(NSString*)longtextname;

CHEDC(help);
CDECL(help) command:(NSString*)command;

CHEDC(rebuildlogics);
CDECL(rebuildlogics);

CDECL(displaycommand) command:(NSString*)command;

@property (readonly) NSMutableArray* commands;

@property (retain) id<KMCommandInterpreterLogic> defaultTarget;

@property (retain) KMConnectionCoordinator* coordinator;

@property (retain) NSMutableDictionary* logics;

@property (retain) NSMutableArray* myLogics;
@end

@interface KMCommandInterpreter ()

-(BOOL) KM_validateInput:(KMCommandInfo*)command forCoordinator:(id)coordinator onlyFlagsAndLevel:(BOOL)ofl;

-(KMCommandInfo*) KM_findCommandByName:(NSString*)name;

-(void) KM_rebuildLogics:(id)coordinator;

@end