//
//  KMPlayingLogic.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/13/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMCommandInterpreterLogic.h"

@interface KMPlayingLogic : NSObject <KMCommandInterpreterLogic> {

}

CHEDC(save);
CDECL(save);

CHEDC(quit);
CDECL(quit);

CHEDC(north);
CDECL(north);

CHEDC(south);
CDECL(south);

CHEDC(east);
CDECL(east);

CHEDC(west);
CDECL(west);

CHEDC(up);
CDECL(up);

CHEDC(down);
CDECL(down);

CHEDC(look);
CDECL(look) direction:(NSString*)dir;

CHEDC(reboot);
CDECL(reboot);

@end
