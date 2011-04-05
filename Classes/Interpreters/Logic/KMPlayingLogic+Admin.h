//
//  KMPlayingLogic+Admin.h
//  KittyMUD
//
//  Created by Michael Tindal on 1/10/11.
//  Copyright 2011 Michael Tindal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMPlayingLogic.h"

@interface KMPlayingLogic (AdminLogic)

CHEDC(setstat);
CDECL(setstat) character:(NSString*)character name:(NSString*)name value:(int)value;

CHEDC(invis);
CDECL(invis);

CHEDC(setflag);
CDECL(setflag) character:(NSString*)character flag:(NSString*)flag;

CHEDC(clearflag);
CDECL(clearflag) character:(NSString*)character flag:(NSString*)flag;

CHEDC(isflagset);
CDECL(isflagset) character:(NSString*)character flag:(NSString*)flag;

@end
