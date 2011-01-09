//
//  KMRoom.m
//  KittyMUD
//
//  Created by Michael Tindal on 10/12/09.
//  Copyright 2009 Michael Tindal. All rights reserved.
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as 
// published by the Free Software Foundation; either version 3 of 
// the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
//

#import "KMRoom.h"
#import "KMConnectionCoordinator.h"
#import "KMConnectionPool.h"
#import "KMServer.h"

static NSMutableArray* rooms;

@implementation KMRoom

extern KMExitDirection directionFromString( NSString* dir );

+(void)initData
{
	NSArray* roomsToLoad = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[@"$(KMRoomSourceDir)" replaceAllVariables] error:NULL];
	
	if(!roomsToLoad)
		return;
	
	for(NSString* roomToLoad in roomsToLoad) {
		if(![[roomToLoad substringWithRange:NSMakeRange([roomToLoad length] - 4, 4)] isEqualToString:@".xml"])
			continue;
		NSArray* room = [KMRoom loadRoomWithPath:[[NSString stringWithFormat:@"$(KMRoomSourceDir)/%@",roomToLoad] replaceAllVariables]];
		OCLog(@"kittymud",info,@"Adding rooms for sector %@...", [[room objectAtIndex:0] sector]);
		[rooms addObjectsFromArray:room];
	}
	OCLog(@"kittymud",info,@"Resolving exits...");
	[KMRoom resolveExits:YES];
}	

+(id)customLoader:(NSXMLElement*)xelem withContext:(void*)context {
	NSArray* directions = [NSArray arrayWithObjects:@"north",@"south",@"west",@"east",@"up",@"down",nil];
	for(NSString* dir in directions) {
		NSArray* dirs = [xelem elementsForName:dir];
		if([dirs count] > 0) {
			NSXMLElement* element = [dirs objectAtIndex:0];
			KMExitInfo* exit = [[KMExitInfo alloc] init];
			KMExitDirection direction = KMExitNorth;
			if([dir isEqualToString:@"north"])
				direction = KMExitNorth;
			else if([dir isEqualToString:@"south"])
				direction = KMExitSouth;
			else if([dir isEqualToString:@"west"])
				direction = KMExitWest;
			else if([dir isEqualToString:@"east"])
				direction = KMExitEast;
			else if([dir isEqualToString:@"up"])
				direction = KMExitUp;
			else if([dir isEqualToString:@"down"])
				direction = KMExitDown;
			[exit setDirection:direction];
			NSXMLNode* destination = [element attributeForName:@"id"];
			[exit setDestination:[destination stringValue]];
			NSArray* locks = [element elementsForName:@"lock"];
			if([locks count] > 0) {
				[exit setIsLocked:YES];
				NSXMLNode* lockid = [[locks objectAtIndex:0] attributeForName:@"id"];
				[exit setLockId:[lockid stringValue]];
			}
			KMRoom** room = (KMRoom**)context;
			[[*room exitInfo] addObject:exit];
		}
	}
	return nil;
}

-(id) init
{
	self = [super init];
	if(self) {
		exitInfo = [[NSMutableArray alloc] init];
	}
	return self;
}

+(void) resolveExits:(BOOL)remove
{
	for(KMRoom* room in rooms) {
        BOOL roomsEdited;
        do {
            roomsEdited = NO;
            for(KMExitInfo* exit in [room exitInfo]) {
                NSString* sectorString = nil;
                NSString* roomString = [[NSString alloc] init];
                NSScanner* scanner = [NSScanner scannerWithString:[exit destination]];
                [scanner scanString:@"[" intoString:NULL];
                [scanner scanUpToString:@"::" intoString:&roomString];
                if(![scanner isAtEnd]) {
                    [scanner scanString:@"::" intoString:NULL];
                    sectorString = [roomString copy];
                    roomString = [[scanner string] substringFromIndex:[scanner scanLocation]];
                    NSScanner* rs = [NSScanner scannerWithString:roomString];
                    [rs scanUpToString:@"]" intoString:&roomString];
                }
                
                NSPredicate* exitTest;
                if(sectorString)
                    exitTest = [NSPredicate predicateWithFormat:@"self.sector like[cd] %@ and self.roomID like[cd] %@", sectorString, roomString];
                else 
                    exitTest = [NSPredicate predicateWithFormat:@"self.roomID like[cd] %@",roomString];
                NSArray* roomsWhichPass = [rooms filteredArrayUsingPredicate:exitTest];
                if([roomsWhichPass count] > 0) {
                    if([roomsWhichPass count] > 1) {
                        OCLog(@"kittymud",info,@"Ambiguous reference for exit %@ in room %@.", [exit destination], [room roomID]);
                        if(remove) {
                            OCLog(@"kittymud",info,@"Removing exit %@ from room %@.", [exit destination], [room roomID]);
                            [[room exitInfo] removeObject:exit];
                        }
                        continue;
                    }
                    [exit setRoom:[roomsWhichPass objectAtIndex:0]];
                } else {
                    OCLog(@"kittymud",info,@"Unable to resolve exit %@ in room %@.", [exit destination], [room roomID]);
                    if(remove) {
                        OCLog(@"kittymud",info,@"Removing exit %@ from room %@.", [exit destination], [room roomID]);
                        [[room exitInfo] removeObject:exit];
                        roomsEdited = YES;
                        break;
                    }
                    continue;
                }
            }
        } while(roomsEdited);
	}
}

+(KMRoom*) getRoomByName:(NSString*)name {
	
	NSString* sectorString = nil;
	NSString* roomString = [[NSString alloc] init];
	NSScanner* scanner = [NSScanner scannerWithString:name];
	[scanner scanString:@"[" intoString:NULL];
	[scanner scanUpToString:@"::" intoString:&roomString];
	if(![scanner isAtEnd]) {
		[scanner scanString:@"::" intoString:NULL];
		sectorString = [roomString copy];
		roomString = [[scanner string] substringFromIndex:[scanner scanLocation]];
		NSScanner* rs = [NSScanner scannerWithString:roomString];
		[rs scanUpToString:@"]" intoString:&roomString];
	}
	
	NSPredicate* exitTest;
	if(sectorString)
		exitTest = [NSPredicate predicateWithFormat:@"self.sector like[cd] %@ and self.roomID like[cd] %@", sectorString, roomString];
	else 
		exitTest = [NSPredicate predicateWithFormat:@"self.roomID like[cd] %@",name];
	NSArray* roomsWhichPass = [rooms filteredArrayUsingPredicate:exitTest];
	if([roomsWhichPass count] > 0)
		return [roomsWhichPass objectAtIndex:0];
	return nil;
}
			
				
+(NSArray*) getAllRooms
{
	return (NSArray*)rooms;
}

+(void) addRooms:(NSArray*)_rooms {
    if(!rooms) {
		rooms = [[NSMutableArray alloc] init];
	}
	for(id obj in _rooms) {
		if([obj isKindOfClass:[KMRoom class]]) {
			[rooms addObject:obj];
		}
	}
}

+(NSArray*) loadRoomWithPath:(NSString*)path {
	NSMutableArray* myrooms = [[NSMutableArray alloc] init];
	
	NSFileHandle* fh = [NSFileHandle fileHandleForReadingAtPath:path];
	if(fh == nil)
		return nil;
	
	NSXMLDocument* xdoc = [[NSXMLDocument alloc] initWithData:[fh readDataToEndOfFile] options:0 error:NULL];
	
	if(xdoc == nil)
		return nil;
	
	NSXMLElement* sectorElement = [xdoc rootElement];
	
	if(![[sectorElement name] isEqualToString:@"sector"])
		return nil;
	NSXMLNode* sectorIdAttribute = [sectorElement attributeForName:@"id"];
	NSString* sectorId = [sectorIdAttribute stringValue];
	
	NSArray* roomElements = [sectorElement elementsForName:@"room"];
	for(NSXMLElement* roomElement in roomElements) {
		NSXMLNode* roomIdAttribute = [roomElement attributeForName:@"id"];
		NSString* roomId = [roomIdAttribute stringValue];
		NSXMLNode* defaultAttribute = [roomElement attributeForName:@"default"];
		KMRoom* room = [[KMRoom alloc] init];
		[room setSector:sectorId];
		[room setRoomID:roomId];
		if(defaultAttribute)
			[room setIsDefault:[[defaultAttribute stringValue] boolValue]];
		NSXMLElement* titleElement = [[roomElement elementsForName:@"title"] objectAtIndex:0];
		[room setRoomTitle:[titleElement stringValue]];
		NSXMLElement* descriptionElement = [[roomElement elementsForName:@"description"] objectAtIndex:0];
		[room setRoomDescription:[descriptionElement stringValue]];
		NSArray* exitsElement = [roomElement elementsForName:@"exits"];
		if([exitsElement count] > 0) {
			[self customLoader:[exitsElement objectAtIndex:0] withContext:&room];
		}
		[myrooms addObject:room];
	}
	return myrooms;
}

+(KMRoom*) getDefaultRoom {
	NSPredicate* defaultRoom = [NSPredicate predicateWithFormat:@"self.isDefault == yes"];
	NSArray* room = [rooms filteredArrayUsingPredicate:defaultRoom];
	if([room count] > 0)
		return [room objectAtIndex:0];
	return nil;
}

-(KMExitInfo*) getExit:(KMExitDirection)direction
{
	NSPredicate* exitPred = [NSPredicate predicateWithFormat:@"self.direction == %d", direction];
	NSArray* exit = [exitInfo filteredArrayUsingPredicate:exitPred];
	if([exit count] > 0)
		return [exit objectAtIndex:0];
	return nil;
}

+(void) debugPrintInfo {
	for(KMRoom* room in rooms) {
		OCLog(@"kittymud",info,@"%@::%@ (%@)", [room sector], [room roomID], [room roomTitle]);
		for(KMExitInfo* exit in [room exitInfo]) {
			NSString* direction = @"north: ";
			switch([exit direction]) {
				case KMExitNorth:
					direction = @"north: ";
					break;
				case KMExitSouth:
					direction = @"south: ";
					break;
				case KMExitEast:
					direction = @"east: ";
					break;
				case KMExitWest:
					direction = @"west: ";
					break;
				case KMExitUp:
					direction = @"up: ";
					break;
				case KMExitDown:
					direction = @"down: ";
					break;
			}
			OCLog(@"kittymud",info,@"  %@%@,%@::%@", direction, [exit destination], [[exit room] sector], [[exit room] roomID]);
		}
	}
}

-(void) displayRoom:(id)coordinator {
	NSMutableString* string = [[NSMutableString alloc] init];
	[string appendString:[self roomTitle]];
	[string appendString:@"\n\r\n\r"];
	[string appendString:[self roomDescription]];
    [string appendString:@"\n\r\n\r"];
    [string appendString:@"`w("];
    NSArray* conns = [[[KMServer getDefaultServer] getConnectionPool] connections];
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"self.character.room.sector == %@ and self.character.room.roomID == %@",self.sector,self.roomID];
    NSArray* array = [conns filteredArrayUsingPredicate:pred];
    for(KMConnectionCoordinator* coord in array) {
        [string appendFormat:@" `y%@ ",[[coord valueForKeyPath:@"character.properties.name"] capitalizedString]];
    }
    [string appendString:@"`w)"];
	[string appendString:@"\n\r`B[ "];
	NSArray* exits = [NSArray arrayWithObjects:@"north",@"south",@"west",@"east",@"up",@"down",nil];
	for(NSString* exit in exits) {
		KMExitDirection dir = directionFromString(exit);
		NSPredicate* exitPred = [NSPredicate predicateWithFormat:@"self.direction == %d", dir];
		NSArray* exitA = [[self exitInfo] filteredArrayUsingPredicate:exitPred];
		if([exitA count] > 0) {
			KMExitInfo* exitI = [exitA objectAtIndex:0];
			if([exitI isLocked])
				[string appendFormat:@" `w(`R%@`w) ", exit];
			else
				[string appendFormat:@" `R%@ ", exit];
		}
	}
	[string appendString:@"`B]`x"];
	[coordinator sendMessageToBuffer:string];
}

-(NSString*) stringValue {
	return [NSString stringWithFormat:@"[%@::%@]", [self sector], [self roomID]];
}

@synthesize roomID;
@synthesize exitInfo;
@synthesize roomTitle;
@synthesize roomDescription;
@synthesize sector;
@synthesize isDefault;

@end
