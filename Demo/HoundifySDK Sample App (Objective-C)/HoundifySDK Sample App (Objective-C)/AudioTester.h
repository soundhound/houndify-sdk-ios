//
//  AudioTester.h
//  HoundSDK Test Application
//
//  Created by Cyril Austin on 6/2/15.
//  Copyright (c) 2015 SoundHound, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Callbacks

typedef void (^AudioTesterDataHandler)(NSError* error, NSData* data);
typedef void (^AudioTesterErrorHandler)(NSError* error);

#pragma mark - Errors

extern NSString* AudioTesterErrorDomain;

typedef NS_ENUM(NSUInteger, AudioTesterErrorCode)
{
    AudioTesterErrorCodeNone,
    AudioTesterErrorCodePermissionDenied
};

#pragma mark - AudioTester

@interface AudioTester : NSObject

+ (instancetype)instance;

- (void)startAudioWithSampleRate:(double)sampleRate dataHandler:(AudioTesterDataHandler)handler;
- (void)stopAudioWithHandler:(AudioTesterErrorHandler)handler;

@end
