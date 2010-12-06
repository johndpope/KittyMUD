//
//  KMEventEngine.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/3/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "KMEventEngine.h"


@implementation KMEventEngine

- (id)init {
    if ((self = [super init])) {
        handlers = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)dealloc {
    // Clean-up code here.
    
    [super dealloc];
}
-(void) fireEvent:(NSString*)event withArguments:(NSArray*)args {
    if(![handlers objectForKey:event])
        return;
    
    NSArray* _handlers = [handlers objectForKey:event];
    for(ECSFunction* func in _handlers) {
        ECSFunction* fcall = [[ECSFunction alloc] initCallWithName:func arguments:args];
        [fcall evaluateWithContext:nil];
    }
}

-(void) registerHandler:(ECSFunction*)handler forEvent:event {
    if(![handlers objectForKey:event])
        [handlers setObject:[NSMutableArray array] forKey:event];
    
    NSMutableArray* _handlers = [handlers objectForKey:event];
    [_handlers addObject:handler];
}

@synthesize handlers;
@end
