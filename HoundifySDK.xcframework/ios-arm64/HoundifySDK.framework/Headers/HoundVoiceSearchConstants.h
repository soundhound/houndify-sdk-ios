//
//  HoundVoiceSearchConstants.h
//  HoundSDK
//
//  Created by Cyril Austin on 10/9/15.
//  Copyright © 2015 SoundHound, Inc. All rights reserved.
//

#ifndef HoundVoiceSearchConstants_h
#define HoundVoiceSearchConstants_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Notifications

/**
 HoundVoiceSearchStateChangeNotification is posted whenever the
 currently active HoundVoiceSearchQuery changes its state, and
 whenever the listening state of the SDK changes. The following fields
 are available in the `userInfo` dictionary of the notification:

 HoundVoiceSearchQueryKey                    : The query whose state changed. (Can be empty.)
 HoundVoiceSearchQueryStateKey               : The current state of the current query.
 HoundVoiceSearchListeningKey                : An NSNumber wrapped boolean of the current
                                               listening state of the SDK.
 HoundVoiceSearchListeningRestartOnActiveKey : Contains an NSNumber **YES** if the listening
                                               state changed to true due to the application
                                               returning to active state
*/
extern NSString* HoundVoiceSearchStateChangeNotification;
extern NSString* HoundVoiceSearchQueryKey;
extern NSString* HoundVoiceSearchQueryStateKey;
extern NSString* HoundVoiceSearchListeningKey;
extern NSString* HoundVoiceSearchListeningRestartOnActiveKey;

/**
 HoundVoiceSearchAudioLevelNotification is posted in listening mode
 with the current audio level.  The audio level is a number between 0
 and 1 containing the current audio level from the microphone. This
 can be used for visualization purposes.  The level value is stored as
 an NSNumber object in the object property of the notification. It can
 be read using:
 
 [notification.object floatValue]
 */
extern NSString* HoundVoiceSearchAudioLevelNotification;

/**
 During the **Recording** phase of a HoundVoiceSearchQuery,
 HoundVoiceSearchPartialTranscriptionNotification broadcasts partial
 transcriptions as they are received.
 
 notification.object is of type HoundDataPartialTranscript
 */
extern NSString* HoundVoiceSearchPartialTranscriptionNotification;

/**
 HoundVoiceSearchFinalTranscriptionNotification broadcasts the final
 transcription once a response arrives for a query. The string value
 is in:
 
 notification.userInfo[@"finalTranscription"]
 */
extern NSString* HoundVoiceSearchFinalTranscriptionNotification;

#pragma mark - HoundVoiceSearchState (Deprecated)

typedef NS_ENUM(NSUInteger, HoundVoiceSearchState)
{
    HoundVoiceSearchStateNone,
    HoundVoiceSearchStateReady,
    HoundVoiceSearchStateRecording,
    HoundVoiceSearchStateSearching,
    HoundVoiceSearchStateSpeaking
};

#pragma mark - HoundifyStyle

@interface HoundifyStyle : NSObject

@property(nullable, nonatomic, strong) UIColor* backgroundColor;
@property(nullable, nonatomic, strong) UIColor* backgroundOverlayColor;
@property(nullable, nonatomic, copy) NSString* fontName;
@property(nullable, nonatomic, strong) UIColor* textColor;
@property(nullable, nonatomic, strong) UIColor* buttonTintColor;
@property(nullable, nonatomic, strong) UIColor* ringColor;
@property(nonatomic, assign) BOOL useWhiteAttribution;
@property(nullable, nonatomic, weak) id helpTarget;
@property(nullable, nonatomic, assign) SEL helpSelector;
@property(nullable, nonatomic, copy) NSString* titleText;
@property(nullable, nonatomic, copy) NSString* subtitleText;
@property(nullable, nonatomic, copy) NSString* hintTitleText;
@property(nullable, nonatomic, copy) NSString* hintSubtitleText;

@end

NS_ASSUME_NONNULL_END

#endif
