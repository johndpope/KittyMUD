//
//  KMChooseClassState.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/11/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMState.h"
#import "KMMenuHandler.h"
#import "KMObject.h"

@interface  KMChooseClassState  : KMObject <KMState> {
	NSArray* klasses;
	KMMenuHandler* menu;
}

-(id)init;

@property (retain) NSArray* klasses;
@property (retain) KMMenuHandler* menu;
@end
