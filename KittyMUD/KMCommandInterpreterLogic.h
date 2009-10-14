//
//  KMCommandInterpreterLogic.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/7/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
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
