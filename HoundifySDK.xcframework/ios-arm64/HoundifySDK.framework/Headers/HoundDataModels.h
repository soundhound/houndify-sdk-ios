//
//  HoundDataModels.h
//  Hound Command Parser
//
//  Created by Cyril Austin on 6/4/15.
//  Copyright (c) 2015 SoundHound, Inc. All rights reserved.
//

#ifndef HoundDataModels_h
#define HoundDataModels_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - HoundData

@interface HoundData : NSObject

@property(nullable, nonatomic, strong, readonly) NSDictionary* _dictionary;

#if !IGNORE_SUBSCRIPT_OPERATOR

- (id __nullable)objectForKeyedSubscript:(NSString*)key;

#endif

@end

NS_ASSUME_NONNULL_END

#endif

