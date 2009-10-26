//
//  XDFNumberReference.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/25/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XDFReference.h"

@interface XDFNumberReference : XDFReference
{
	NSNumber* myNum;
}

@property (retain) NSNumber* myNum;
@end;

@interface XDFNumberReference ()

-(id) initializeWithNumber:(NSNumber*)number;

@end