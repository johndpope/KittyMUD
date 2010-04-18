//
//  KMEnumFactory.h
//  KittyMUD
//
//  Created by Michael Tindal on 1/31/10.
//  Copyright 2010 Michael Tindal. All rights reserved.
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

// expansion macro for enum value definition
#define KMEF_ENUM_VALUE(name,assign,string) name assign,

// expansion macro for enum to string conversion
#define KMEF_ENUM_CASE(name,assign,string) case name: return string;

// expansion macro for enum to string conversion
#define KMEF_ENUM_STRCMP(name,assign,string) if([str isEqualToString:string]) return name;

/// declare the access function and define enum values
#define KMDeclareEnum(Prefix,EnumType,KMEF_ENUM_DEF) \
  typedef enum { \
    KMEF_ENUM_DEF(KMEF_ENUM_VALUE) \
  } Prefix##EnumType; \
  NSString* NSStringFrom##EnumType(Prefix##EnumType dummy); \
  Prefix##EnumType Prefix##EnumType##FromString(NSString* string); \

/// define the access function names
#define KMDefineEnum(Prefix,EnumType,KMEF_ENUM_DEF) \
 NSString* NSStringFrom##EnumType(Prefix##EnumType value) \
  { \
    switch(value) \
    { \
      KMEF_ENUM_DEF(KMEF_ENUM_CASE) \
      default: return @""; /* handle input error */ \
    } \
  } \
  Prefix##EnumType Prefix##EnumType##FromString(NSString* str) \
  { \
    KMEF_ENUM_DEF(KMEF_ENUM_STRCMP) \
    return (Prefix##EnumType)0; /* handle input error */ \
  } \
