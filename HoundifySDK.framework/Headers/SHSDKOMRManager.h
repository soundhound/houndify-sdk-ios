//
//  SHSDKOMRManager.h
//  HoundSDK
//
//  Created by Sean Kelly on 8/7/17.
//  Copyright © 2017 SoundHound, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>
#import "SHSoundHoundDataModels.h"

#pragma mark - SHSDKOMRManagerState

typedef NS_ENUM(NSUInteger, SHSDKOMRManagerState)
{
    SHSDKOMRManagerStateNone,
    SHSDKOMRManagerStateRecording,
    SHSDKOMRManagerStateSearching
};

#pragma mark - Callbacks

typedef void (^SHSDKOMRManagerCallback)(NSError* error, NSString *jsonResponse, SHDataSoundHoundMelodis *melodis);

#pragma mark - Notifications

extern NSString* SHSDKOMRManagerStateChangeNotification;

#pragma mark - SHSDKOMRManager

@interface SHSDKOMRManager : NSObject

@property(nonatomic, assign, readonly) SHSDKOMRManagerState state;

+ (instancetype)instance;

- (void)startSearchWithCompletionHandler:(SHSDKOMRManagerCallback)completionHandler
    withClientID:(NSString*)clientID
    clientKey:(NSString*)clientKey
    userAgent:(NSString*)userAgent
    SDK:(BOOL)SDK;
- (void)stopSearch;
- (void)cancelSearch;

@end
