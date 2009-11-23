//
//  KMStatAllocationLogic.h
//  KittyMUD
//
//  Created by Michael Tindal on 10/8/09.
//  Copyright 2009 Gravinity Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KMCommandInterpreterLogic.h"
#import "KMCommandInterpreter.h"
#import "KMStat.h"
#import "KMObject.h"

#ifndef F
#define F(x) 1 << x
#endif

typedef enum {
	KMStatAllocationIncrease = F(0),
	KMStatAllocationDecrease = F(1),
	KMStatAllocationReset = F(2),
} KMStatAllocationChangeType;

@interface  KMStatAllocationLogic  : KMObject <KMCommandInterpreterLogic> {
	@protected
	KMStat* base;
	KMStat* allocBase;
	BOOL copiedAllocatable;
	NSMutableArray* validStats;
}

CHEDC(increase);
CDECL(increase) stat:(NSString*)stat withValue:(int)value;

CHEDC(decrease);
CDECL(decrease) stat:(NSString*)stat withValue:(int)value;

CHEDC(reset);
CDECL(reset) stat:(NSString*)stat;

CHEDC(save);
CDECL(save);

CHEDC(quit);
CDECL(quit);

CHEDC(showvalid);
CDECL(showvalid);

-(void) displayStatAllocationScreenToCoordinator:(id)coordinator;

-(BOOL) confirmStats:(id)coordinator;

@property (retain) KMStat* base;
@property (retain) KMStat* allocBase;
@property BOOL copiedAllocatable;
@property (retain) NSMutableArray* validStats;
@end
