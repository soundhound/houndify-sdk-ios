//
//  HoundRequestInfoBuilder.h
//  HoundSDK
//
//  Created by Jeff Weitzel on 1/23/18.
//  Copyright © 2018 SoundHound, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *HoundRequestInfoBuilderErrorDomain;

/**
 A wrapper around the Houndify RequestInfo dictionary.
 
 "RequestInfo" is a dictionary that is passed with requests to the houndify server.
 
 Clients may use requestInfo for applications like sending houndify the user's
 location, or specifying special queries for houndify to parse, among many others.
 
 See https://docs.houndify.com/reference/RequestInfo for documentation of some the
 keys that can be used.
 
 HoundRequestInfoBuilder provides a convenient means to set values in the RequestInfo
 dictionary.
 */
@interface HoundRequestInfoBuilder : NSObject

@property (nonatomic, readonly) NSDictionary<NSString *, id> *requestInfo;

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) NSInteger positionTime;
@property (nonatomic, assign) double positionHorizontalAccuracy;
@property (nonatomic, copy, nullable) NSString *street;
@property (nonatomic, copy, nullable) NSString *city;
@property (nonatomic, copy, nullable) NSString *state;
@property (nonatomic, copy, nullable) NSString *country;
@property (nonatomic, assign) BOOL controllableTrackPlaying;
@property (nonatomic, assign) NSInteger timeStamp;
@property (nonatomic, copy, nullable) NSString *timeZone;
@property (nonatomic, copy, nullable) NSDictionary *conversationState;
@property (nonatomic, copy, nullable) NSDictionary *clientState;
@property (nonatomic, strong, nullable) NSObject *sendBack;
@property (nonatomic, copy, nullable) NSArray *preferredImageSize;
@property (nonatomic, copy, nullable) NSString *inputLanguageEnglishName;
@property (nonatomic, copy, nullable) NSString *inputLanguageNativeName;
@property (nonatomic, copy, nullable) NSString *inputLanguageIETFTag;
@property (nonatomic, copy, nullable) NSString *outputLanguageEnglishName;
@property (nonatomic, copy, nullable) NSString *outputLanguageNativeName;
@property (nonatomic, copy, nullable) NSString *outputLanguageIETFTag;
@property (nonatomic, assign) double resultVersionAccepted;
@property (nonatomic, copy, nullable) NSString *unitPreference;
@property (nonatomic, copy, nullable) NSString *clientID;
@property (nonatomic, copy, nullable) NSString *clientVersion;
@property (nonatomic, copy, nullable) NSString *deviceID;
@property (nonatomic, copy, nullable) NSString *sdk;
@property (nonatomic, copy, nullable) NSDictionary *sdkInfo;
@property (nonatomic, copy, nullable) NSString *firstPersonSelf;
@property (nonatomic, copy, nullable) NSString *firstPersonSelfSpoken;
@property (nonatomic, copy, nullable) NSArray *secondPersonSelf;
@property (nonatomic, copy, nullable) NSArray *secondPersonSelfSpoken;
@property (nonatomic, copy, nullable) NSString *wakeUpPattern;
@property (nonatomic, copy, nullable) NSString *userID;
@property (nonatomic, copy, nullable) NSString *requestID;
@property (nonatomic, copy, nullable) NSString *sessionID;
@property (nonatomic, copy, nullable) NSDictionary *domains;
@property (nonatomic, assign) BOOL resultUpdateAllowed;
@property (nonatomic, assign) BOOL partialTranscriptsDesired;
@property (nonatomic, assign) NSUInteger minResults;
@property (nonatomic, assign) NSUInteger maxResults;
@property (nonatomic, assign) BOOL objectByteCountPrefix;
@property (nonatomic, copy, nullable) NSArray *clientMatches;
@property (nonatomic, assign) BOOL clientMatchesOnly;
@property (nonatomic, copy, nullable) NSString *responseAudioVoice;
@property (nonatomic, copy, nullable) NSString *responseAudioShortOrLong;
@property (nonatomic, copy, nullable) NSArray *responseAudioAcceptedEncodings;
@property (nonatomic, copy, nullable) NSDictionary *voiceActivityDetection;
@property (nonatomic, assign) BOOL intentOnly;
@property (nonatomic, assign) BOOL disableSpellCorrection;
@property (nonatomic, assign) BOOL useContactData;
@property (nonatomic, assign) BOOL useClientTime;
@property (nonatomic, assign) NSInteger forceConversationStateTime;
@property (nonatomic, copy, nullable) NSArray *userContactsRequests;
@property (nonatomic, copy, nullable) NSString *OAuth2RefreshToken;

#pragma mark - Adhoc Methods
- (id _Nullable)objectForAdHocKey:(NSString *)key;

/**
 Add a key value pair to RequestInfo for which there is no setter.
 
 For instance, to use a key that has been added since the release of this version
 of the Houndify SDK.
 
 Use with care, there is no validation on values set with this method

 @param anObject the value
 @param aKey the key
 */
- (void)setObject:(id)anObject forAdhocKey:(NSString *)aKey;

/**
 Import an existing RequestInfo dictionary. Use with care, there is no validation.

 @param dictionary an existing RequestInfo dictionary
 */
- (void)addAdhocEntriesFromDictionary:(NSDictionary<NSString *, id> *)dictionary;

/**
 Remove an object from the RequestInfo dictionary using its key.

 @param aKey the key to remove
 */
- (void)removeObjectForAdhocKey:(NSString *)aKey;


@end

NS_ASSUME_NONNULL_END
