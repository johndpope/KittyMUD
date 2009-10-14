//
//  KMDataStartup.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/5/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol KMDataStartup

+(void)initData;

@end

@protocol KMDataCustomLoader

+(id)customLoader:(NSXMLElement*)xelem withContext:(void*)context;

@end
