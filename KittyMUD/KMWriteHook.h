//
//  KMWriteHook.h
//  KittyMUD
//
//  Created by Michael Tindal on 9/16/09.
//  Copyright 2009 Gravinity Games. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol KMWriteHook

-(NSString*) processHook:(NSString*) input;

@end
