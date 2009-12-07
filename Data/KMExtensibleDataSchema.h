//
//  XDFSchema.h
//  XDF
//
//  Created by Michael Tindal on 10/31/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol KMExtensibleDataSchema

-(NSString*) dataType;

-(NSString*) keyForTag:(NSString*)tag;

-(NSString*) keyForAttribute:(NSString*)attribute onTag:(NSString*)tag;

-(NSInvocation*) invocationToLoadKey:(NSString*)key;

-(Class) schemaType;

@end
