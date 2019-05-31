//
//  SHAudioManager.h
//  SHHound
//
//  Created by Sean Kelly on 3/6/17.
//  Copyright © 2017 SoundHound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHAudioDestinationProtocol.h"
#import "SHAudioRecordingManager.h"

#pragma mark - Errors

extern NSString* SHAudioManagerErrorDomain;

typedef NS_ENUM(NSUInteger, SHAudioManagerErrorCode)
{
    SHAudioManagerErrorCodeNone,
    SHAudioManagerErrorCodePermissionDenied,
    SHAudioManagerErrorCodeApplicationNotActive,
    SHAudioManagerErrorCodeStartDisallowed,
};

#pragma mark - Notifications

extern NSString* SHAudioManagerRenderDidFailNotification;
extern NSString* SHAudioManagerDidDetectLevelNotification;
extern NSString* SHAudioManagerDidDetectAudioNotification;

#define SHAUDIOMANAGER_DID_START @"SHAudioManagerDidStartNotification"
#define SHAUDIOMANAGER_WILL_STOP @"SHAudioManagerWillStopNotification"
extern NSString* SHAudioManagerDidStartNotification;
extern NSString* SHAudioManagerWillStopNotification;
extern NSString* SHAudioManagerRestartedOnActive;

#pragma mark - Callbacks

typedef void (^SHAudioManagerErrorCallback)(NSError* error);
typedef BOOL (^SHAudioManagerConsultApplicationCallback)(void);

#pragma mark - SHAudioManager

@interface SHAudioManager : NSObject

@property(nonatomic, assign, readonly) BOOL isListening;
@property(nonatomic, assign, readonly) BOOL permissionDenied;
@property(nonatomic, assign, readonly) BOOL isUsingBluetooth;

@property(nonatomic, assign, readonly) float magnitudeThreshold;
@property(nonatomic, assign, readonly) float magnitudeMaximum;

@property(nonatomic, readonly) NSString *currentAudioCategory;
@property(nonatomic, assign, readonly) BOOL currentAudioCategoryAllowsRecording;

+ (instancetype)instance;

@property(atomic, assign, readonly) double hardwareSampleRate;
@property(atomic, assign, readonly) double outputSampleRate;

@property(atomic, strong, readonly) SHAudioRecordingManager* recordingManager;

@property (nonatomic, copy) SHAudioManagerConsultApplicationCallback audioStartAllowedBlock;
@property (nonatomic, copy) SHAudioManagerConsultApplicationCallback audioShouldDeactivateBlock;

- (void)configureWithPreferredInputSampleRate:(double)preferredInputSampleRate
    preferredOutputSampleRate:(double)preferredOutputSampleRate
    captureFrequencySpectrum:(BOOL)captureFrequencySpectrum
    useFacetimeMicrophone:(BOOL)useFacetimeMicrophone
    allowBluetooth:(BOOL)allowBluetooth
    rollingCacheLength:(NSTimeInterval)audioCacheLength
    rawMode:(BOOL)rawMode;

- (NSError*)setCategoryForAudioSession:(NSString*)audioSessionCategory;

- (void)startListeningWithCompletionHandler:(SHAudioManagerErrorCallback)handler;
- (void)stopListeningWithCompletionHandler:(SHAudioManagerErrorCallback)handler;
- (void)pauseListeningForExitWithCompletionHandler:(SHAudioManagerErrorCallback)handler;
- (void)resumeListeningWithCompletionHandler:(SHAudioManagerErrorCallback)handler;

- (void)addAudioDestination:(id<SHAudioDestination>)audioDestination;
- (void)addAudioDestination:(id<SHAudioDestination>)audioDestination withRewindIndex:(NSUInteger)rewindIndex;
- (void)removeAudioDestination:(id<SHAudioDestination>)audioDestination;

- (void)writeRawAudioData:(NSData*)data;

- (BOOL)hasCachedAudioFileName:(NSString*)fileName;
- (void)cacheAudioWithFileName:(NSString*)fileName;
- (void)cacheAudioWithFileName:(NSString*)fileName fileType:(NSString *)fileType;
- (void)cacheAudioWithFileName:(NSString *)fileName fileType:(NSString *)fileType completion:(dispatch_block_t)completion;
- (void)cacheAudioWithFilePath:(NSString*)filePath forName:(NSString*)name;
- (void)playCachedAudioWithFileName:(NSString*)fileName;
- (void)playCachedAudioWithFileName:(NSString *)fileName autoRepeat:(BOOL)autoRepeat;
- (void)stopCachedAudioPlayback;
- (void)clearCachedAudio;

@end
