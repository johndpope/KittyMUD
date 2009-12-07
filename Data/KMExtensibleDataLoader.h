//
//  XDFLoader.h
//  XDF
//
//  Created by Michael Tindal on 10/31/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XSHRuntime/XSHRuntime.h>
#import "KMExtensibleDataSchema.h"

@interface KMExtensibleDataLoader : XSHRoot {

}

-(NSArray*) loadFile:(NSString*)path withSchema:(id<KMExtensibleDataSchema>)schema;

@end
