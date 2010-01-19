//
//  KMConfirmStatAllocationState.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/11/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import "KMConfirmStatAllocationState.h"
#import "KMStatAllocationState.h"
#import "KMChooseClassState.h"


@implementation KMConfirmStatAllocationState

-(void) processState:(id)coordinator
{
	NSString* message = [coordinator getInputBuffer];
	NSPredicate* yesPredicate = [NSPredicate predicateWithFormat:@"self beginswith[cd] 'y'"];
	if([yesPredicate evaluateWithObject:message]) {
		KMGetStateFromCoordinator(state);
		if(state == self) {
			KMSetStateForCoordinatorTo([KMNullState class]);
		}
	}
	return;
}

+(NSString*) getName
{
	return @"ConfirmStatAllocation";
}

// Because soft reboot under KittyMUD does not discriminate based on the state, we use this so we can remind players what they were doing after a soft reboot
-(void) softRebootMessage:(id)coordinator {
	KMSoftRebootCheck;
	[coordinator sendMessageToBuffer:@"Do you wish to continue with these stats (yes/no):"];
}
@end
