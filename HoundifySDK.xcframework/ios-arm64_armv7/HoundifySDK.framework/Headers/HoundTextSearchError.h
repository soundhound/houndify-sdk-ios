//
//  HoundTextSearchError.h
//  SHHound
//
//  Created by Jeff Weitzel on 1/12/18.
//  Copyright © 2018 SoundHound. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Errors

extern NSString* HoundTextSearchErrorDomain;

#pragma mark - HoundVoiceSearchErrorCode

typedef NS_ENUM(NSInteger, HoundTextSearchErrorCode)
{
    HoundTextSearchErrorCodeNone,
    HoundTextSearchErrorCodeAuthenticationFailed,
    HoundTextSearchErrorCodeServerStatusError,
    HoundTextSearchErrorCodeCorruptRequestInfo
};


@interface HoundTextSearchError : NSError

- (instancetype)initWithCode:(HoundTextSearchErrorCode)code description:(NSString *)description;
- (instancetype)initWithCode:(HoundTextSearchErrorCode)code userInfo:(NSDictionary<NSErrorUserInfoKey,id> *)dict;

+ (instancetype)authenticationFailed;
+ (instancetype)serverStatus;
+ (instancetype)corruptRequestInfo:(NSDictionary *)userInfo;

- (instancetype)initWithDomain:(NSErrorDomain)domain code:(NSInteger)code userInfo:(NSDictionary<NSErrorUserInfoKey,id> *)dict __attribute__((unavailable("Use convenience methods")));

@end
