//
//  HoundVoiceSearchError.h
//  HoundSDK
//
//  Created by Jeff Weitzel on 10/13/17.
//  Copyright © 2017 SoundHound, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* HoundVoiceSearchErrorDomain;

typedef NS_ENUM(NSUInteger, HoundVoiceSearchErrorCode)
{
    HoundVoiceSearchErrorCodeNone,                  // 0
    HoundVoiceSearchErrorCodeCancelled,             // 1
    HoundVoiceSearchErrorCodeNotReady,              // 2
    HoundVoiceSearchErrorCodeServerStatusError,     // 3
    HoundVoiceSearchErrorCodeServerNoAudioError,    // 4
    HoundVoiceSearchErrorCodeNoResponseReceived,    // 5
    HoundVoiceSearchErrorCodeInvalidResponse,       // 6
    HoundVoiceSearchErrorCodeAudioInterrupted,      // 7
    HoundVoiceSearchErrorCodeParseFailed,           // 8
    HoundVoiceSearchErrorCodeAuthenticationFailed,  // 9
    HoundVoiceSearchErrorCodeInternalError,         // 10
    HoundVoiceSearchErrorCodePermissionDenied,      // 11
    HoundVoiceSearchErrorCodeApplicationNotActive,  // 12
    HoundVoiceSearchErrorCodeConnectionFailure,     // 13
    HoundVoiceSearchErrorCodeConnectionTimeout,     // 14
    HoundVoiceSearchErrorCodeAudioStartDisallowed,  // 15
    HoundVoiceSearchErrorCodeQueryStartDisallowed,  // 16
    HoundVoiceSearchErrorCodeCorruptRequestInfo     // 17
};

@interface HoundVoiceSearchError : NSError

- (instancetype)initWithCode:(HoundVoiceSearchErrorCode)code description:(NSString *)description;
- (instancetype)initWithCode:(HoundVoiceSearchErrorCode)code userInfo:(NSDictionary<NSErrorUserInfoKey,id> *)dict;

+ (NSError *)errorForInternalError:(NSError *)error;

+ (instancetype)canceled;
+ (instancetype)notReady;
+ (instancetype)serverStatus;
+ (instancetype)noAudio;
+ (instancetype)noResponseReceived;
+ (instancetype)invalidResponse;
+ (instancetype)audioInterrupted;
+ (instancetype)parseFailed;
+ (instancetype)authenticationFailed;
+ (instancetype)internalError;
+ (instancetype)permissionDenied;
+ (instancetype)applicationNotActive;
+ (instancetype)connectionFailure;
+ (instancetype)connectionTimeout;
+ (instancetype)queryStartDisallowed;
+ (instancetype)corruptRequestInfo;

- (instancetype)initWithDomain:(NSErrorDomain)domain code:(NSInteger)code userInfo:(NSDictionary<NSErrorUserInfoKey,id> *)dict __attribute__((unavailable("Use convenience methods")));
@end
