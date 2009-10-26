//
//  XDFFunctionInfo.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/25/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XDFFunctionInfo : NSObject {
	id target;
	NSString* name;
	NSString* selector;
}

@property (retain) id target;
@property (retain) NSString* name;
@property (retain) NSString* selector;
@end
