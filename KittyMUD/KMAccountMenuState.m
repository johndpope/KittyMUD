//
//  KMAccountMenuState.m
//  KittyMUD
//
//  Created by Michael Tindal on 9/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "KMAccountMenuState.h"
#import "KMAccountMenu.h"

static NSMutableArray* menuItems;

@implementation KMAccountMenuState

+(void)load
{
	menuItems = [[NSMutableArray alloc] init];
	Class*__attribute__((objc_gc(strong))) classes;
	int numClasses = objc_getClassList(NULL, 0);
	
	classes = malloc(sizeof(Class) * numClasses);
	objc_getClassList(classes, numClasses);
	for(int i = 0; i < numClasses; i++) {
		Class c = classes[i];
		if(class_respondsToSelector(c,@selector(conformsToProtocol:))) {
			if([c conformsToProtocol:@protocol(KMAccountMenu)]) {
				NSLog(@"Adding %@ to account menu items with priority %d", [c className], [c priority]);
				[menuItems addObject:c];
			}
		}
	}
}

@end
