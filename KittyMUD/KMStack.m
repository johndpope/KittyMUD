//
//  KMStack.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/11/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMStack.h"


@implementation KMStack

-(id) init
{
	self = [super init];
	if(self) {
		items = [[NSMutableArray alloc] init];
	}
	return self;
}

-(id) pop
{
	if([items count] == 0)
		return nil;
	
	id item = [items objectAtIndex:0];
	[items removeObjectAtIndex:0];
	return item;
}

-(void) push:(id)obj
{
	[items insertObject:obj atIndex:0];
}

-(id) peek
{
	if([items count] == 0)
		return nil;
	
	id item = [items objectAtIndex:0];
	return item;
}

@synthesize items;
@end
