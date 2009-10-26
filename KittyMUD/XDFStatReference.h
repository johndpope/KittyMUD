//
//  XDFStatReference.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/25/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XDFReference.h"

@interface XDFStatReference : XDFReference {
	NSString* statName;
}

@property (retain) NSString* statName;
@end

@interface XDFStatReference ()

-(id) initializeWithName:(NSString*)name;

@end