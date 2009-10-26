//
//  KMChooseJobState.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/11/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMState.h"
#import "KMMenuHandler.h"
@interface KMChooseJobState : NSObject <KMState> {
	NSArray* jobs;
	KMMenuHandler* menu;
}

-(id)init;

@property (retain) NSArray* jobs;
@property (retain) KMMenuHandler* menu;
@end
