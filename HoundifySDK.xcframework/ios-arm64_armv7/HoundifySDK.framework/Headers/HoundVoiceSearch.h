//
//  HoundVoiceSearch.h
//  HoundSDK
//
//  Created by Cyril Austin on 5/20/15.
//  Copyright (c) 2015 SoundHound, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoundVoiceSearchConstants.h"
#import "HoundSDKServerDataModels.h"
#import "HoundServerPartialTranscriptDataModels.h"
#import "HoundVoiceSearchQuery.h"

extern NSString * _Nonnull const HoundVoiceSearchDefaultEndpoint;
extern NSString * _Nonnull const HoundVoiceSearchDidBeginListeningNotification;
extern NSString * _Nonnull const HoundVoiceSearchWillStopListeningNotification;

@class HoundifyPhraseSpottingManager;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - HoundVoiceSearchResponseType

typedef NS_ENUM(NSUInteger, HoundVoiceSearchResponseType)
{
    HoundVoiceSearchResponseTypeNone,
    HoundVoiceSearchResponseTypePartialTranscription,
    HoundVoiceSearchResponseTypeHoundServer
};

#pragma mark - Callbacks

typedef void (^HoundVoiceSearchErrorCallback)(NSError* __nullable error);

typedef void (^HoundVoiceSearchResponseCallback)(
    NSError* __nullable error,
    HoundVoiceSearchResponseType responseType,
    id __nullable response,
    NSDictionary<NSString*, id>* __nullable dictionary,
    NSDictionary<NSString*, id>* __nullable requestInfo
);

typedef BOOL (^HoundVoiceSearchPermissionCallback)(void);


#pragma mark - HoundVoiceSearch

/**
 This class provides access to voice search functionality..
 
 HoundifySDK has two modes of audio input: automatic and raw. 

 For most applications, automatic is the easiest choice. In automatic
 mode, the SDK manages audio recording and playback within the
 application. This means that the AVAudioSession activation, category,
 and option settings will be managed by the SDK without any setup by
 the developer. The category is set to
 AVAudioSessionCategoryPlayAndRecord, with the options
 AVAudioSessionCategoryOptionDefaultToSpeaker and
 AVAudioSessionCategoryOptionAllowBluetooth. When
 startListeningWithCompletionHandler: is called, the AVAudioSession is
 activated and microphone audio is recorded by the SDK. When
 stopListeningWithCompletionHandler: is called, the AVAudioSession is
 deactivated and recording stops. Listening must be active to begin a
 voice search.

 If your application has other audio functionality and you prefer to
 manage your AVAudioSession yourself, raw mode allows the application
 to retain complete control over its audio environment. In raw mode,
 the application is responsible for supplying raw audio data to the
 SDK. To initiate raw mode, first call
 setupRawModeWithInputSampleRate:completionHandler: with the sample
 rate used for the audio that will be passed into the SDK. The
 application provides audio data to the SDK using the
 writeRawAudioData: method. Whenever you receive audio data from the
 microphone, pass the audio to the SDK using this method to ensure
 proper voice search behavior. Note that this means that
 startListeningWithCompletionHandler: and
 stopListeningWithCompletionHandler: are not a part of the raw mode
 process.
*/

@interface HoundVoiceSearch : NSObject

/**
 returns the singleton instance of HoundVoiceSearch.
 */
+ (instancetype)instance;

/** 
 Returns true if the Houndify audio chain is active. Hot Phrase Detection
 is only possible when the SDK is listening.
*/
@property(nonatomic, assign, readonly) BOOL isListening;


/**
 A flag indicating if the SDK should automatically detect the Hound
 hot phrase.
 
 If this flag is enabled and the SDK is in receiving audio, when the
 user speaks “OK Hound”, the SDK will post the
 HoundVoiceSearchHotPhraseNotification to all listeners.
 
 To support a hot phrase, an application is responsible for activating
 a voice search when this notification is observed.
 
 The default is YES.
 */
@property(nonatomic, assign) BOOL enableHotPhraseDetection;


/**
 A flag indicating if the SDK should automatically detect end of user
 speech.
 
 By default, the search result is processed as soon as the user stops
 speaking.  If this property is set to NO, -finishRecording must be
 called on the active HoundVoiceSearchQuery, to move it from the
 Recording phase to Searching.
 
 The default is YES.
 */
@property(atomic, assign) BOOL enableEndOfSpeechDetection;


/**
 A callback allowing the application to prevent the SDK's audio chain
 from deactivating.
 
 If the SDK was not started in Raw mode, in certain cirmcumstances it
 will automatically stop listening, and then start listening again
 when appropriate. Most notably, the SDK will stop listening and
 relinquish the audio session when the app enters the background, and
 when the app returns to the foreground, listening will restart
 automatically.
 
 If the application needs to prevent the SDK from deactivating the
 audio session automatically, for instance because the application
 will play back audio in the background, audioShouldDeactivateBlock
 can be supplied.
 
 If it exists, audioShouldDeactivateBlock will be called before the
 audio session is deactivated, and if it returns NO, the audio session
 will not be deactivated.
 */

@property (nonatomic, copy) HoundVoiceSearchPermissionCallback audioShouldDeactivateBlock;

/**
 A callback allowing the application to prevent the SDK's audio chain
 from starting automatically.
 
 If the SDK was not started in Raw mode, in certain cirmcumstances it
 will automatically stop listening, and then start listening again
 when appropriate. Most notably, the SDK will stop listening and
 relinquish the audio session when the app enters the background, and
 when the app returns to the foreground, listening will restart
 automatically.
 
 If the application has a need to prevent listening from restarting
 automatically, for instance because the application needs to retain
 control of the audio session, allowStartListeningBlock can be
 supplied.
 
 If it exists, allowStartListeningBlock will be called before
 listening starts, and if it returns NO, listening will not start and
 an error will be returned.
 */
@property (nonatomic, copy) HoundVoiceSearchPermissionCallback allowStartListeningBlock;


/**
 Access to the SDKs phraseSpottingManager.
 
 The SDK keeps an instance of HoundifyPhraseSpottingManager to handle
 phrase spotting.  This property provides access to that instance for
 the purpose of adjusting phrase spotting sensitivity. The most likely
 scenario in which such access would be needed is if the application
 uses a custom phrase spotter provided by SoundHound.
 */
@property (nonatomic, readonly) HoundifyPhraseSpottingManager *phraseSpottingManager;

#pragma mark - Raw Mode Methods

/**
 This method places the SDK into raw search mode. This method is used
 when the application manages its own audio infrastructure.
 
 If the application doesn’t manage its own audio infrastructure, use 
        @code startListeningWithCompletionHandler: @endcode instead.

 @param inputSampleRate The sampling rate of the audio that will be
 passed into the SDK through <b>writeRawAudioData:</b>.
 @param handler This callback is invoked on the main thread when the
 initalization is complete.
 */
- (void)setupRawModeWithInputSampleRate:(double)inputSampleRate completionHandler:(HoundVoiceSearchErrorCallback __nullable)handler;

/**
 This method allows the caller to supply raw audio data.
 
 @code setupRawModeWithInputSampleRate @endcode 
must be called before writing raw audio data.
 
 @param data The data must be 16 bit, Linear PCM audio data. 16 Khz is
 ideal for optimal performance.  This data is the same as returned by
 the AudioUnitRender API function in the iOS AudioToolbox framework.
 */
- (void)writeRawAudioData:(NSData*)data;

#pragma mark - Automatic Mode Methods

/**
 This method places the SDK into automatic listening mode.

 This method must be successfully called before phrase spotting will
 work. It is recommended, though not required, that it be called
 before starting any voice searches.
 
 The SDK will automatically prompt the user for microphone permissions
 if necessary. If the user declines microphone permissions then an
 error will be returned through the handler.
 
  @note The AVAudioSession for the application will be placed in the
  AVAudioSessionCategoryPlayAndRecord category and
  AVAudioSessionModeDefault mode
 
 @param handler This callback is invoked on the main thread when the
 initalization is complete.
 */
- (void)startListeningWithCompletionHandler:(HoundVoiceSearchErrorCallback __nullable)handler;

/**
 This method stops the SDK from processing microphone input.
 
 @param handler This callback is invoked on the main thread when the
 listening is stopped.
 */
- (void)stopListeningWithCompletionHandler:(HoundVoiceSearchErrorCallback __nullable)handler;

#pragma mark - Voice Search

/**
 Creates a configured instance of HoundVoiceSearchQuery.
 
 To support voice searches, the application should provide an implementation of
 HoundVoiceSearchQueryDelegate.
 
 To perform a voice search, obtain a configured instance of HoundVoiceSearchQuery
 from -newVoiceSearch.
 
 Set the new query's delegate property, so that your application can receive updates
 about the query's progress and results when the query is complete.
 
 Perform any additional needed configuration on the new query instance, including
 updates to the query's requestInfoBuilder.
 
 Call -start on the new query.
 
 @seealso See HoundVoiceSearchQuery.h for more information on how to perform voice searches.

 @return a configured instance of HoundVoiceSearchQuery.
 */
- (HoundVoiceSearchQuery *)newVoiceSearch;

#pragma mark - Deprecated Search Methods

/**
 DEPRECATED. A flag indicating if the SDK should automatically speak the response
 from the server.
 
 This property is only honored by -startSearchWithRequestInfo:
 
 When using HoundVoiceSearchQuery, the application is responsible for initiating speech.
 
 The default is YES.
 */
@property(atomic, assign) BOOL enableSpeech DEPRECATED_MSG_ATTRIBUTE("This property has been deprecated. Use HoundVoiceSearchQuery -speakResponse.");

/**
 DEPRECATED. The current state of voice search.
 */
@property(nonatomic, assign, readonly) HoundVoiceSearchState state DEPRECATED_MSG_ATTRIBUTE("This property has been deprecated. Use HoundVoiceSearchQuery.state instead.");

/**
 DEPRECATED. This method initiates a voice search using the default URL.
 
 Audio is automatically recorded from the user and transmitted to the server.
 
 Use -newVoiceSearch and HoundVoiceSearchQuery -start instead.

 @param requestInfo A dictionary containing extra parameters for the search.
                     The following keys are set by default if not supplied by the caller:
                     UserID, RequestID, TimeStamp, TimeZone, ClientID, ClientVersion, DeviceID, ConversationState, UnitPreference, PartialTranscriptsDesired, ObjectByteCountPrefix, SDK, SDKVersion. See https://houndify.com/reference/RequestInfo
 @param responseHandler This callback is invoked during the search and may be called multiple times with different values. It is always called on the main thread.
 */
- (void)startSearchWithRequestInfo:(NSDictionary<NSString*, id>* __nullable)requestInfo
    responseHandler:(HoundVoiceSearchResponseCallback __nullable)responseHandler DEPRECATED_MSG_ATTRIBUTE("This method has been deprecated. Use -newVoiceSearch.");

/**
 DEPRECATED. This method initiates a voice search. Audio is automatically recorded from the user and transmitted to the server.
 Use the method above if you are not using a custom endpoint for voice search.
 
 @param requestInfo A dictionary containing extra parameters for the search.
                     The following keys are set by default if not supplied by the caller:
                     UserID, RequestID, TimeStamp, TimeZone, ClientID, ClientVersion, DeviceID, ConversationState, UnitPreference, PartialTranscriptsDesired, ObjectByteCountPrefix, SDK, SDKVersion. See https://houndify.com/reference/RequestInfo
 @param endPointURL The URL for a custom Houndify voice search endpoint.
 @param responseHandler This callback is invoked during the search and may be called multiple times with different values. It is always called on the main thread.
 */
- (void)startSearchWithRequestInfo:(NSDictionary<NSString*, id>* __nullable)requestInfo
    endPointURL:(NSURL*)endPointURL
    responseHandler:(HoundVoiceSearchResponseCallback __nullable)responseHandler DEPRECATED_MSG_ATTRIBUTE("This method has been deprecated. Use -newVoiceSearch.");

// General methods

/**
 DEPRECATED. This stops the SDK from listening to the user’s request, and transitions into the searching state.
 
 Applies only to searches started with -startSearchWithRequestInfo:
 
 The search may also be stopped internally when the SDK detects end of user speech if the enableEndOfSpeechDetection flag is YES.
 */
- (void)stopSearch DEPRECATED_MSG_ATTRIBUTE("This method has been deprecated. It applies only to searches started with -startSearchWithRequestInfo:");

/**
 DEPRECATED. The method cancels the search in progress.
 
 Applies only to searches started with -startSearchWithRequestInfo:
 */
- (void)cancelSearch DEPRECATED_MSG_ATTRIBUTE("This method has been deprecated. It applies only to searches started with -startSearchWithRequestInfo:");

/**
 DEPRECATED. If the response is currently being spoken, the method stops speech in progress.
 
 Applies only to searches started with -startSearchWithRequestInfo:
 */
- (void)stopSpeaking DEPRECATED_MSG_ATTRIBUTE("This method has been deprecated. It applies only to searches started with -startSearchWithRequestInfo:");

@end

NS_ASSUME_NONNULL_END
