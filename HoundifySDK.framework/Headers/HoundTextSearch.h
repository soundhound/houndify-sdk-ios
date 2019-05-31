//
//  HoundTextSearch.h
//  HoundSDK
//
//  Created by Cyril Austin on 5/20/15.
//  Copyright (c) 2015 SoundHound, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoundSDKServerDataModels.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const HoundTextSearchDefaultEndpoint;

#pragma mark - Callbacks

/**
 HoundTextSearchCallback
 
 This callback is used only with the "Classic" HoundTextSearch API

 @param error Text search error returned by the server. Nullable.
 @param query Text query submitted.
 @param houndServer A HoundDataHoundServer object.
 @param dictionary A JSON representation of the response.
 @param requestInfo A JSON representation of the request info.
 */
typedef void (^HoundTextSearchCallback)(
    NSError* __nullable error,
    NSString* query,
    HoundDataHoundServer* __nullable houndServer,
    NSDictionary<NSString*, id>* __nullable dictionary,
    NSDictionary<NSString*, id>* __nullable requestInfo
);

#pragma mark - HoundTextSearch

@class HoundTextSearchQuery;

@interface HoundTextSearch : NSObject

/**
 Returns a singleton instance of HoundTextSearch.
 */
+ (instancetype)instance;

/**
 Call this method to obtain a configured instance of HoundTextSearchQuery,
 the first step of performing a Houndify text search.
 
 Perform any additional needed configuration on the returned HoundTextSearchQuery
 instance. For example, location information can be added to the query by setting
 values on the instance's requestInfoBuilder.
 
 To perform the search, call -startWithCompletion: on the query.
 
 Results are returned via the completion block, or via the query's delegate.
 
 @param searchText The text that will be searched for when the query is started.
 @return A configured instance of HoundTextSearchQuery
 */
- (HoundTextSearchQuery *)newTextSearchWithSearchText:(NSString *)searchText;

#pragma mark - HoundTextSearch Classic

// The following methods from the 1.x vintage Houndify SDK are still supported
// They offer less flexibility than -newTextSearchWithSearchText:

/**
 Performs text-based Hound queries using the default endpoint, results are returned in the completion handler.
 
 @note The caller should populate the location keys in requestInfo. The SDK does not manage the user location.
 For a full description of parameters, refer to: https://houndify.com/reference/RequestInfo
 
 @param query Text query
 @param requestInfo A dictionary containing extra parameters for the search.
                     The following keys are set by default if not supplied by the caller:
                     UserID, RequestID, TimeStamp, TimeZone, ClientID, ClientVersion, DeviceID, ConversationState, UnitPreference, PartialTranscriptsDesired, ObjectByteCountPrefix, SDK, SDKVersion
 @param handler The completion handler.
 */
- (void)searchWithQuery:(NSString*)query
    requestInfo:(NSDictionary<NSString*, id>* __nullable)requestInfo
    completionHandler:(HoundTextSearchCallback __nullable)handler;

/**
 Performs text-based Hound queries, results are returned in the completion handler.
 Use the method above if you are not using a custom endpoint for text search.

 @note: The caller should populate the location keys in requestInfo. The SDK does not manage the user location.
 
 @param query Text query
 @param requestInfo A dictionary containing extra parameters for the search.
                     The following keys are set by default if not supplied by the caller:
                     UserID, RequestID, TimeStamp, TimeZone, ClientID, ClientVersion, DeviceID, ConversationState, UnitPreference, PartialTranscriptsDesired, ObjectByteCountPrefix, SDK, SDKVersion
                     For a full description of parameters, refer to: https://houndify.com/reference/RequestInfo
 @param endPointURL The URL for a custom Houndify text search endpoint.
 @param handler The completion handler.
 */
- (void)searchWithQuery:(NSString*)query
    requestInfo:(NSDictionary<NSString*, id>* __nullable)requestInfo
    endPointURL:(NSURL*)endPointURL
    completionHandler:(HoundTextSearchCallback __nullable)handler;

/**
 Cancels a currently in progress text search originating from a -searchWithQuery:... method.
 */
- (void)cancelSearch;

/**
 A flag indicating if the SDK is currently executing a text search from a -searchWithQuery:... method.
 */
@property(nonatomic, assign, readonly) BOOL textSearchActive;



@end

NS_ASSUME_NONNULL_END
