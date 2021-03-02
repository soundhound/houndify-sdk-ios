//
//  HoundVoiceSearchQuery.h
//  HoundSDK
//
//  Created by Jeff Weitzel on 9/1/17.
//  Copyright © 2017 SoundHound, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The five phases in the life cycle of a HoundVoiceSearchQuery instance.

 - HoundVoiceSearchQueryStateNotStarted: Initial state
 - HoundVoiceSearchQueryStateRecording: HoundifySDK is listening for speech and streaming
   audio to the Houndify server for transcription. Calling -start causes the query to enter
   this state.
 - HoundVoiceSearchQueryStateSearching: HoundifySDK is no longer streaming audio for this
   search, and the Houndify server is preparing a response.
 - HoundVoiceSearchQueryStateSpeaking: Calling -speakResponse after a response has been
   received moves the query into this state.
 - HoundVoiceSearchQueryStateFinished: This query is complete, and another query can begin.
 */
typedef NS_ENUM(NSUInteger, HoundVoiceSearchQueryState) {
    HoundVoiceSearchQueryStateNotStarted = 0,
    HoundVoiceSearchQueryStateRecording,
    HoundVoiceSearchQueryStateSearching,
    HoundVoiceSearchQueryStateSpeaking,
    HoundVoiceSearchQueryStateFinished,
};



@protocol HoundVoiceSearchQueryDelegate;
@class HoundDataHoundServer;
@class HoundRequestInfoBuilder;

/**
 HoundVoiceSearchQuery represents a single voice search across its entire life cycle.
 
 In most cases, the application should begin a voice search by obtaining a configured instance
 of HoundVoiceSearchQuery from @code HoundVoiceSearch -newVoiceSearch @endcode
 
 Set the query's delegate.
 
Configure the query as needed, including setting values on the requestInfoBuilder.
 
 Call -start.
 
 As the query progresses through the stages of its life cycle, it will call its delegate
 to provide updates.
 
 */
@interface HoundVoiceSearchQuery : NSObject

@property (nonatomic, weak, nullable) id<HoundVoiceSearchQueryDelegate> delegate;

/**
 Set this property if your application uses a special instance of the Houndify server.
 
 HoundVoiceSearch -newVoiceSearch configures this property to the default value, https://api.houndify.com/v1/audio
 */
@property (nonatomic, strong, nullable) NSURL *endPointURL;

/**
 The current phase of the query's lifecycle.
 */
@property (nonatomic, readonly) HoundVoiceSearchQueryState state;

/**
 Modify this object to make changes to the RequestInfo dictionary that will be sent
 to the Houndify server to initiate this search.
 
 A common reason to do this is to include location information with the search.
 
 See HoundRequestInfoBuilder.h and https://docs.houndify.com/reference/RequestInfo
 for more information on what you can do with requestInfo.
 */
@property (nonatomic, readonly, nonnull) HoundRequestInfoBuilder *requestInfoBuilder;

/**
 true when the query is in any state other than NotStarted or Finished
 
 Only one HoundVoiceSearchQuery instance may be active at a time.
 */
@property (nonatomic, readonly) BOOL isActive;

/**
 Once a response has been received, it is available via this property
 */
@property (nonatomic, readonly, nullable) HoundDataHoundServer *response;

/**
 Once a response has been received, the undecoded keys and values are available
 via this property
 */
@property (nonatomic, readonly, nullable) NSDictionary<NSString*, id>* dictionary;

/**
 Once a response has been received, the transcription is available via this property
 */
@property (nonatomic, readonly, nullable) NSString *transcription;

/**
 If a query ends with an error, it is made available via this property
 */
@property (nonatomic, readonly, nullable) NSError *error;

/**
 When true, a query will advance automatically from the Recording to the Searching phase
 
 During the Recording phase of the query's lifecycle, if this property is true, the SDK
 will detect when the user has stopped speaking and automatically advance to the Searching
 phase.
 
 HoundVoiceSearch -newVoiceSearch configures this property to the value of
 HoundVoiceSearch -enableEndOfSpeechDetection, which in turn defaults to true.
 */
@property (nonatomic, assign) BOOL automaticEndOfSpeech;


/**
 An IETF BCP 47 language tag (e.g. "en", "en-US")
 
 When -speakResponse is called, this value is passed to the iOS speech synthesizer
 to determine what voice to use for speech, so only values for which iOS has a voice
 are meaningful.
 
 If the application does not set this value explicitly, at query start time it will be set to the
 value of requestInfoBuilder.outputLanguageIETFTag, if there is one, or
 requestInfoBuilder.inputLanguageIETFTag.
 
 If both of these are unset, it will default to "en".
 */
@property (nonatomic, copy, nullable) NSString *languageCode;

/**
 If true, automatically activate the SDK's audio chain before starting the query, if needed.
 
 Before a voice query enters the Recording phase, it checks whether the audio chain in the
 SDK is listening.
 
 If startAudioIfNeeded is false, and the SDK is not listening, the query will fail and pass
 an error to its delegate.
 
 If startAudioIfNeeded is true, and the SDK is not listening, the query will attempt to start
 the audio chain before it enters the Recording phase. This is the same as calling
 HoundVoiceSearch -startListeningWithCompletionHandler:
 
 Leaving startAudioIfNeeded set to true will make an application more robust against unexpected
 failures of the audio chain to start, so this is recommended unless the application needs to
 carefully manage when the SDK takes control of the audio session.
 
 The default value is true.
 */
@property (nonatomic, assign) BOOL startAudioIfNeeded;

/**
 Attempts to move the query into the Recording phase.
 
 Only one HoundVoiceSearchQuery instance may receive audio from the audio chain at a time,
 and it is the responsibility of the application to cancel any currently active query, or
 wait for it to complete, before starting a new one. Calling start while another query is
 active will result in the new query failing with an error.
 */
- (void)start;

/**
 Forces the query to move from the Recording phase to the Searching phase.
 */
- (void)finishRecording;

/**
 Immediately halts the query, no matter what its current phase.
 
 -houndVoiceSearchQueryDidCancel: is called on the delegate, and the query moves to state
 Finished.
 */
- (void)cancel;

/**
 Send the spokenResponse property of the query's response to the iOS system speech synthesizer.
 
 Moves the query into state Speaking.
 
 Has no effect if the query's response property is nil.
 */
- (void)speakResponse;

/**
 Halt speech if the query is Speaking, and move immediately to state Finished
 */
- (void)stopSpeaking;


@end

@class HoundDataPartialTranscript;

@protocol HoundVoiceSearchQueryDelegate <NSObject>

/**
 Called whenever a query moves between phases.

 @param query The calling HoundVoiceSearchQuery instance
 @param oldState The phase before the change
 @param newState The current phase
 */
- (void)houndVoiceSearchQuery:(HoundVoiceSearchQuery * _Nonnull)query changedStateFrom:(HoundVoiceSearchQueryState)oldState to:(HoundVoiceSearchQueryState)newState;

/**
 Called when a query receives a transcription from Houndify.
 
 During the Recording phase, the SDK continuously streams audio to the Houndify server, and the
 Houndify server continuously regenerates its speech to text transcription as it gets new audio,
 and returns updates to the SDK as the transciption changes.
 
 The query calls this method whenever it receives a transcription from server.
 
 The application can present these updates to the user as feedback while they speak.
 
 @note After query completes, the final transcription should be obtained from the returned
 HoundDataHoundServer object. It can also be obtained from the transcription property of the query.
 

 @param query The calling HoundVoiceSearchQuery instance
 @param partialTranscript A HoundDataPartialTranscript object. The transcription text can be
 obtained from its partialTranscript property.
 */
- (void)houndVoiceSearchQuery:(HoundVoiceSearchQuery * _Nonnull)query didReceivePartialTranscription:(HoundDataPartialTranscript *_Nonnull)partialTranscript;

/**
 Called when a query receives a result from Houndify server, at the end of the Searching phrase.

 @param query The calling HoundVoiceSearchQuery instance
 @param houndServer A HoundDataHoundServer object containing the results returned by the server.
 This object is also available via the query's response property. See
 https://docs.houndify.com/reference/HoundServer for information on this data structure.
 @param dictionary The undecoded response dictionary returned by the server. The HoundDataHoundServer
 object in the houndServer parameter is derived from this dictionary. It is also available
 via the query's dictionary property.
 */
- (void)houndVoiceSearchQuery:(HoundVoiceSearchQuery * _Nonnull)query didReceiveSearchResult:(HoundDataHoundServer * _Nonnull)houndServer dictionary:(NSDictionary * _Nonnull)dictionary;

/**
 Called if a query fails with an error.

 @param query The calling HoundVoiceSearchQuery instance
 @param error The error. The error's localizedDescription property may contain helpful information.
 */
- (void)houndVoiceSearchQuery:(HoundVoiceSearchQuery * _Nonnull)query didFailWithError:(NSError * _Nonnull)error;

/**
 Called if a query ends because it was cancelled.

 @param query The calling HoundVoiceSearchQuery instance
 */
- (void)houndVoiceSearchQueryDidCancel:(HoundVoiceSearchQuery * _Nonnull)query;

@end
