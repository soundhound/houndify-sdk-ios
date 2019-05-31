//
//  SHResponseParser.h
//  SHHound
//
//  Created by Cyril Austin on 2/11/15.
//  Copyright (c) 2015 SoundHound. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^SHResponseParserObjectProvider)(Class, NSDictionary *);

#pragma mark - SHResponseParserLazyLoadType

typedef NS_ENUM(NSUInteger, SHResponseParserLazyLoadType)
{
    SHResponseParserLazyLoadTypeNone,
    SHResponseParserLazyLoadTypeSingle,
    SHResponseParserLazyLoadTypeAll
};

#pragma mark - SHResponseParser

@interface SHResponseParser : NSObject

+ (id)objectWithClass:(Class)class fromJSONObject:(NSDictionary*)JSONObject;

+ (id)objectWithClass:(Class)class fromJSONObject:(NSDictionary*)JSONObject
    lazyLoadType:(SHResponseParserLazyLoadType)lazyLoadType;

+ (NSArray *)arrayWithClass:(Class)class fromJSONArray:(NSArray *)JSONArray;

+ (NSString*)propertyNameFromJSONKey:(NSString*)key;

// Selector declaration
+ (Class)classForDictionary:(NSDictionary*)dictionary;
+ (Class)childClassForDictionary:(NSDictionary*)dictionary;
- (NSString*)overriddenCommandKey;

+ (NSDictionary*)ignorableProperties;


/**
 SHResponseParser's objectProvider takes advantage of the permissive
 Objective-C runtime to provide a means to decode JSON dictionaries
 into objects of classes that are not visible inside the SDK.
 
 If an application has an expanded set of HoundData subclasses available to it,
 it can provide SHResponseParser an objectProvider block. The block takes
 a Class and an NSDictionary as arguments.
 
 It should return an instance of the Class or a subclass of the Class
 appropriate for the dictionary.
 
 NOTE: the block is not responsible for decoding the dictionary into the instance.
 SHResponseParser will populate the object's properties from the dictionary.
 */
+ (void)setObjectProvider:(SHResponseParserObjectProvider)objectProvider;
+ (SHResponseParserObjectProvider)objectProvider;

@end
