//
//  KMEventEngine.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/3/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ECScript/ECScript.h>

@interface KMEventEngine : NSObject {
@private
    NSMutableDictionary* handlers;
}

-(void) fireEvent:(NSString*)event withArguments:(NSArray*)args;

-(void) registerHandler:(ECSFunction*)handler forEvent:event;

@property (retain) NSMutableDictionary* handlers;
@end
