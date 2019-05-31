//
//  SHAudioRecordingManager.h
//  Audio
//
//  Created by Cyril Austin on 3/24/15.
//  Copyright (c) 2015 SoundHound, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHAudioDestinationProtocol.h"

#pragma mark - Notifications

extern NSString* SHAudioRecordingManagerFrequencyMagnitudeNotification;

#pragma mark - Callbacks

typedef void (^SHAudioRecordingManagerErrorCallback)(NSError* error);

#pragma mark - SHAudioRecordingManagerDelegate

@class SHAudioRecordingManager;

@protocol SHAudioRecordingManagerDelegate<NSObject>

- (void)audioRecordingManager:(SHAudioRecordingManager*)manager renderDidFailWithError:(NSError*)error;
- (void)audioRecordingManager:(SHAudioRecordingManager*)manager didDetectLevel:(double)level sum:(double)sum;

@end

#pragma mark - SHAudioRecordingManager

@interface SHAudioRecordingManager : NSObject<SHAudioDestination>

@property(nonatomic, weak) id<SHAudioRecordingManagerDelegate> delegate;

@property(nonatomic, assign, readonly) float magnitudeThreshold;
@property(nonatomic, assign, readonly) float magnitudeMaximum;

- (instancetype)initWithAudioDestination:(id<SHAudioDestination>)audioDestination
    sampleRate:(double)sampleRate
    captureFrequencySpectrum:(BOOL)captureFrequencySpectrum
    rawMode:(BOOL)rawMode;

// These will block the calling thread during execution. Do not call from the main thread or any other thread
// that should not be blocked.
- (NSError *)start;
- (NSError *)stop;

- (double)audioLevel;

- (void)writeRawAudioData:(NSData*)data;

+ (BOOL)iPhone6sOrGreater;

- (void)setAudioAnalysisEnabled:(BOOL)audioAnalysisEnabled;
- (void)setMusicMode:(BOOL)musicMode;

@end
