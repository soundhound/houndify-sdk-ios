//
//  HoundDataModelsPrivate.h
//  SHHound
//
//  Created by Cyril Austin on 11/3/15.
//  Copyright © 2015 SoundHound. All rights reserved.
//

#import <Foundation/Foundation.h>
#if HOUND2
#import <HoundifySDK/HoundDataModels.h>
#else
#import "HoundDataModels.h"
#endif

#pragma mark - HoundData

@interface HoundData(Private)

+ (NSString*)forwardField;

+ (NSString*)commandKey;

@property(nonatomic, copy) NSString* subCommandKind;

+ (Class)enumDescriptorForSelector:(SEL)selector;

+ (Class)arrayChildClassForSelector:(SEL)selector;

+ (Class)genericArrayChildClassForSelector:(SEL)selector dictionary:(NSDictionary *)dictionary;

// todo - merge these two at some point
+ (BOOL)ignoreNativeData;
+ (BOOL)ignoreJSONData;

+ (instancetype)instanceFromString:(NSString*)string;
+ (instancetype)instanceFromArray:(NSArray*)array;

- (void)setInternalDictionary:(NSDictionary*)dictionary;

- (BOOL)isValid;
- (BOOL)isValid:(NSError **)error;
+ (NSDictionary *)optionalMap;

@end

#pragma mark - HoundDataEnum

@interface HoundDataEnum : NSObject

+ (NSInteger)valueForString:(NSString*)string;

@end

#pragma mark - Macros

#define BEGIN_ARRAY_CLASS_MAP() + (Class)arrayChildClassForSelector:(SEL)selector \
    { \
    if (NO) { } \

#define ARRAY_CLASS_MAP(property, codeClass) else if (selector == @selector(property)) \
    { \
        return [codeClass class]; \
    }

#define END_ARRAY_CLASS_MAP() if ([[self superclass] respondsToSelector:@selector(arrayChildClassForSelector:)]) \
    { \
    return [[self superclass] arrayChildClassForSelector:selector]; \
    } \
    return nil; \
}


#define BEGIN_ENUM_MAP() + (NSInteger)valueForString:(NSString*)string \
    { NSInteger value = 0; \
    if ([string isEqualToString:@"None"]) { }

#define ENUM_MAP(enum, type) else if ([[string.lowercaseString stringByReplacingOccurrencesOfString:@"-" withString:@""] isEqualToString:[@#type lowercaseString]]) \
    { value = enum##type; }

// CYRIL TODO Remove this assert!

#define END_ENUM_MAP() else { NSAssert(NO, @"unsupported enum values"); } \
    return value; }

#define BEGIN_ENUM_DESCRIPTOR_MAP() + (Class)enumDescriptorForSelector:(SEL)selector \
    { \
    if (NO) { }

#define ENUM_DESCRIPTOR_MAP(sel, c) else if (selector == @selector(sel)) \
    { \
        return c.class; \
    }

#define END_ENUM_DESCRIPTOR_MAP() return [super enumDescriptorForSelector:selector]; \
    }
