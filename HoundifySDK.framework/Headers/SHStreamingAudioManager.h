//
//  SHStreamingAudioManager.h
//  SHHound
//
//  Created by Cyril Austin on 3/30/15.
//  Copyright (c) 2015 SoundHound. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - SHFileStreamerDataFormat

typedef NS_ENUM(NSUInteger, SHStreamingAudioManagerDataFormat)
{
    SHStreamingAudioManagerDataFormatJSON,
    SHStreamingAudioManagerDataFormatXML
};

#pragma mark - SHStreamingAudioResponseFormat

typedef NS_ENUM(NSUInteger, SHStreamingAudioResponseFormat)
{
    SHStreamingAudioResponseFormatNone,
    SHStreamingAudioResponseFormatStream,
    SHStreamingAudioResponseFormatBlock
};

#pragma mark - SHStreamingAudioManagerDelegate

@class SHStreamingAudioManager;

@protocol SHStreamingAudioManagerDelegate<NSObject>

- (void)streamingAudioManagerDidBecomeReady:(SHStreamingAudioManager*)streamingAudioManager
    format:(SHStreamingAudioResponseFormat)format;

- (void)streamingAudioManager:(SHStreamingAudioManager*)streamingAudioManager
    didReceiveData:(NSData*)data
    format:(SHStreamingAudioManagerDataFormat)format
    statusCode:(NSUInteger)statusCode withHeaders:(NSDictionary*)headers;

- (void)streamingAudioManager:(SHStreamingAudioManager*)streamingAudioManager didCompleteWithError:(NSError*)error;

@end

#pragma mark - SHStreamingAudioManager

@interface SHStreamingAudioManager : NSObject

@property(nonatomic, weak) id<SHStreamingAudioManagerDelegate> delegate;

- (void)startStreamingToURL:(NSURL*)URL
    headers:(NSDictionary*)headers
    clientID:(NSString*)clientID
    clientKey:(NSString*)clientKey
    retry:(BOOL)retry
    rewindIndex:(NSNumber *)rewindIndex
    leadingData:(NSData*)data;

- (void)stopStreaming;

- (void)cancelStreaming;

@property(nonatomic, readonly) BOOL didReceiveAudio;


@end
