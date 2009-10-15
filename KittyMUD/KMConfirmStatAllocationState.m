//
//  KMConfirmStatAllocationState.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/11/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMConfirmStatAllocationState.h"
#import "KMStatAllocationState.h"
#import "KMChooseJobState.h"


@implementation KMConfirmStatAllocationState

-(id<KMState>) processState:(id)coordinator
{
	NSString* message = [coordinator getInputBuffer];
	NSPredicate* yesPredicate = [NSPredicate predicateWithFormat:@"self beginswith[cd] 'y'"];
	if([yesPredicate evaluateWithObject:message])
		return [[KMChooseJobState alloc] init];
	NSPredicate* noPredicate = [NSPredicate predicateWithFormat:@"self beginswith[cd] 'n'"];
	if([noPredicate evaluateWithObject:message])
		return [[KMStatAllocationState alloc] init];
	[coordinator sendMessageToBuffer:@"Do you wish to continue with these stats `R(yes/no)`x:"];
	return self;
}

+(NSString*) getName
{
	return @"ConfirmStatAllocation";
}

// Because soft reboot under KittyMUD does not discriminate based on the state, we use this so we can remind players what they were doing after a soft reboot
-(void) softRebootMessage:(id)coordinator {
	[coordinator sendMessageToBuffer:@"Do you wish to continue with these stats (yes/no):"];
}
@end
