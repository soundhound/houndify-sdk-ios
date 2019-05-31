//
//  SHHTTPSocketFileStreamer.h
//  midomi
//
//  Created by Cyril Austin on 5/21/14.
//  Copyright (c) 2014 SoundHound, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHFileStreamer.h"

/******************************************************************************/
#pragma mark - enum SHHTTPSocketFileStreamerError
/******************************************************************************/

extern NSString* const SHHTTPSocketFileStreamerErrorDomain;

typedef NS_ENUM(NSUInteger, SHHTTPSocketFileStreamerError)
{
	kSHHTTPSocketFileStreamerSuccess = 0,
    kSHHTTPSocketFileStreamerErrorCreateReadWriteStreamFailed,
    kSHHTTPSocketFileStreamerErrorSetClientFailed,
    kSHHTTPSocketFileStreamerErrorHTTPSInitializationFailed,
    kSHHTTPSocketFileStreamerErrorConnectionTimeOutExpired,
    kSHHTTPSocketFileStreamerErrorForcedTimeOutExpired,
    kSHHTTPSocketFileStreamerErrorRequestCancelled,
    kSHHTTPSocketFileStreamerErrorReachabilityChanged,
    kSHHTTPSocketFileStreamerErrorUnitTestForcingRetry,
};

/******************************************************************************/
#pragma mark - interface SHHTTPSocketFileStreamer
/******************************************************************************/

@interface SHHTTPSocketFileStreamer : NSObject<SHFileStreamer>

@property(nonatomic, assign, readonly) NSUInteger statusCode;
@property(nonatomic, strong, readonly) NSDictionary* responseHeaders;
@property(nonatomic, strong, readonly) NSData* responseBodyData;
@property(nonatomic, strong, readonly) NSData* streamedFileData;
@property(nonatomic, copy, readonly) NSError* error;
@property(nonatomic, assign) NSTimeInterval retryDuration;

- (id)initWithURLString:(NSString*)URLString
    andExtraHeaders:(NSDictionary*)extraHeaders andEndTags:(NSArray*)endTags;

- (void)forceTimeoutAfterInterval:(NSTimeInterval)timeoutInterval;

+ (NSError*)socketFileStreamerErrorWithCode:(SHHTTPSocketFileStreamerError)errorCode;

@end