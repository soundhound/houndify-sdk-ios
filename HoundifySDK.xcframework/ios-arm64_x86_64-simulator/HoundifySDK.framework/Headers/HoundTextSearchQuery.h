//
//  HoundTextSearchQuery.h
//  SHHound
//
//  Created by Jeff Weitzel on 1/11/18.
//  Copyright © 2018 SoundHound. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HoundTextSearchQuery;
@class HoundDataHoundServer;
@class HoundRequestInfoBuilder;


typedef void (^HoundTextSearchQueryCallback)(HoundTextSearchQuery * _Nonnull query,
                                             HoundDataHoundServer * _Nullable response,
                                             NSError * _Nullable error);


@protocol HoundTextSearchQueryDelegate;

/**
 HoundTextSearchQuery represents a single text search across its entire life cycle.
 
 Once the application has a search string, the application should
 begin a text search by obtaining a configured instance of HoundTextSearchQuery from
 @code HoundTextSearch -newTextSearchWithSearchText: @endcode
 
 Configure the query as needed, including setting values on the requestInfoBuilder.
 
 HoundTextSearchQuery accepts a delegate, so similar result handling code can be used
 between HoundVoiceSearchQuery and HoundTextSearchQuery, but for HoundTextSearchQuery,
 the delegate is not required.
 
 To perform the search, call -startWithCompletion:

 */
@interface HoundTextSearchQuery : NSObject

/**
 The text that will be searched for when the query is started.
 */
@property (nonatomic, copy, nullable) NSString *searchText;

@property (nonatomic, weak, nullable) id<HoundTextSearchQueryDelegate> delegate;

/**
 Set this property if your application uses a special instance of the Houndify server.
 
 HoundTextSearch -newTextSearchWithSearchText: configures this
 property to the default value, https://api.houndify.com/v1/text
 */
@property (nonatomic, strong, nullable) NSURL *endPointURL;

/**
 Modify this object to make changes to the RequestInfo dictionary that will be sent
 to the Houndify server to initiate this search.
 
 A common reason to do this is to include location information with the search.
 
 See HoundRequestInfoBuilder.h and https://docs.houndify.com/reference/RequestInfo
 for more information on what you can do with requestInfo.
 */
@property (nonatomic, readonly, nonnull) HoundRequestInfoBuilder *requestInfoBuilder;

/**
 An IETF BCP 47 language tag (e.g. "en", "en-US")
 
 When -speakResponse if called, languageCode is passed to the iOS speech
 synthesizer to determine what voice to use for speech, so only values
 for which iOS has a voice are meaningful.
 
 If the application does not set this value explicitly, at query start
 time it will be set to the value of
 requestInfoBuilder.outputLanguageIETFTag, if there is one, or
 requestInfoBuilder.inputLanguageIETFTag.
 
 If both of these are unset, it will default to "en".
 */
@property (nonatomic, copy, nonnull) NSString *languageCode;

/**
 Once a response has been received, it is available via this property.
 */
@property (nonatomic, readonly, nullable) HoundDataHoundServer *response;

/**
 Once a response has been received, the undecoded keys and values are available
 via this property.
 */
@property (nonatomic, readonly, nullable) NSDictionary<NSString*, id>* dictionary;

/**
 If a query ends with an error, it is made available via this property.
 */
@property (nonatomic, readonly, nullable) NSError *error;


/**
 Send a request to the Houndify server with the search.
 
 Configure the query as desired before calling this method.

 @param completion Once the query completes, this block will be called with a response
 or an error. If the query completes due to cancellation, it will have neither.
 */
- (void)startWithCompletion:(HoundTextSearchQueryCallback _Nullable )completion;

/**
 Cancel the query if a response is still pending.
 */
- (void)cancel;

/**
 Send the spokenResponse property of the query's response to the iOS system speech synthesizer.
  
 Has no effect if the query's response property is nil.
 */
- (void)speakResponse;

/**
 True while the response is being spoken.
 */
@property (nonatomic, readonly) BOOL isSpeaking;

/**
 Interrupt speech, if the query is playing its spoken response.
 */
- (void)stopSpeaking;

@end

@class HoundDataHoundServer;

@protocol HoundTextSearchQueryDelegate <NSObject>

@optional

/**
 Called when a query receives a result from Houndify server

 @param query The calling HoundTextSearchQuery instance
 @param houndServer A HoundDataHoundServer object containing the results returned by the server.
 This object is also available via the query's response property. See
 https://docs.houndify.com/reference/HoundServer for information on this data structure.
 @param dictionary The undecoded response dictionary returned by the server. The HoundDataHoundServer
 object in the houndServer parameter is derived from this dictionary. It is also available
 via the query's dictionary property.
 */
- (void)houndTextSearchQuery:(HoundTextSearchQuery * _Nonnull)query didReceiveSearchResult:(HoundDataHoundServer * _Nonnull)houndServer dictionary:(NSDictionary * _Nonnull)dictionary;

/**
 Called if a query fails to complete because of an error.


 @param query The calling HoundTextSearchQuery instance
 @param error The error. The error's localizedDescription property may contain helpful information.
 */
- (void)houndTextSearchQuery:(HoundTextSearchQuery * _Nonnull)query didFailWithError:(NSError * _Nonnull)error;

/**
 Called if a query ends because it was cancelled.

 @param query The calling HoundTextSearchQuery instance
 */
- (void)houndTextSearchQueryDidCancel:(HoundTextSearchQuery * _Nonnull)query;


@end
