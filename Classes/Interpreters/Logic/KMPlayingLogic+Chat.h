//
//  KMPlayingLogic+Chat.h
//  KittyMUD
//
//  Created by Michael Tindal on 1/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMPlayingLogic.h"

@interface KMPlayingLogic (ChatLogic)

CHEDC(say);
CDECL(say) message:(NSString*)message;

CHEDC(yell);
CDECL(yell) message:(NSString*)message;

@end
