//
//  KMVariableHook.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/15/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMObject.h"
#import "KMWriteHook.h"

@interface  KMVariableHook  : KMObject <KMWriteHook>
@end