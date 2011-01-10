//
//  KMPlayingLogic+Chat.h
//  KittyMUD
//
//  Created by Michael Tindal on 1/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMPlayingLogic.h"

@interface KMPlayingLogic (SocialLogic)

CHEDC(say);
CDECL(say) message:(NSString*)message;

CHEDC(yell);
CDECL(yell) message:(NSString*)message;

CHEDC(whisper);
CDECL(whisper) target:(NSString*)target message:(NSString*)message;

CHEDC(reply);
CDECL(reply) message:(NSString*)message;

CHEDC(ooc);
CDECL(ooc) message:(NSString*)message;

CHEDC(who);
CDECL(who);

@end
