//
//  KMColorProcessWriteHook.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/14/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMWriteHook.h"

@interface KMColorProcessWriteHook : NSObject <KMWriteHook> {
	NSDictionary* colors;
}

-(id) init;
@property (retain) NSDictionary* colors;
@end
