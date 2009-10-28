//
//  KMMenuHandler.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/5/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMConnectionCoordinator.h"
#import "KMMenu.h"

@interface KMMenuHandler : NSObject {
	NSMutableArray* myItems;
}

-(id)initializeWithItems:(NSArray*)items;

-(void)displayMenu:(KMConnectionCoordinator*)coordinator;

-(void)displayMenu:(KMConnectionCoordinator*)coordinator withSortFunction:(NSInteger (*)(id, id, void *))sortFunction;

-(id)getSelection:(KMConnectionCoordinator*)coordinator;

-(id)getSelection:(KMConnectionCoordinator *)coordinator withSortFunction:(NSInteger (*)(id, id, void *))sortFunction;
@property (retain) NSMutableArray* myItems;
@end
