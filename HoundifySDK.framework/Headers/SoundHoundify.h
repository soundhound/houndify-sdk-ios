//
//  SoundHoundify.h
//  HoundSDK
//
//  Created by Cyril Austin on 12/2/15.
//  Copyright © 2015 SoundHound, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoundVoiceSearch.h"
#import "HoundTextSearch.h"
#import "Houndify.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Callbacks

typedef void (^SoundHoundTextSearchCallback)(
    NSError* __nullable error,
    NSString* query,
    NSData* __nullable data,
    NSDictionary<NSString*, id>* __nullable dictionary,
    NSDictionary<NSString*, id>* __nullable requestInfo
);

#pragma mark - SoundHoundify

@interface SoundHoundify : NSObject

@property(nonatomic, strong) NSDictionary* conversationState;

@property(nonatomic, assign) BOOL enableHotPhrase;

+ (instancetype)instance;

#pragma mark - Voice Search

- (void)setupWithInputSampleRate:(double)inputSampleRate
    completionHandler:(HoundVoiceSearchErrorCallback __nullable)handler;

- (void)writeRawAudioData:(NSData*)data;

- (void)presentListeningViewControllerInViewController:(UIViewController*)presentingViewController
    fromView:(UIView* __nullable)presentingView
    style:(HoundifyStyle* __nullable)style
    requestInfo:(NSDictionary<NSString*, id>* __nullable)requestInfo
    endPointURL:(NSURL*)endPointURL
    responseHandler:(HoundifyResponseCallback_deprecated __nullable)responseHandler;

- (void)presentListeningViewControllerInViewController:(UIViewController*)presentingViewController
    fromPoint:(CGPoint)point
    style:(HoundifyStyle* __nullable)style
    requestInfo:(NSDictionary<NSString*, id>* __nullable)requestInfo
    endPointURL:(NSURL*)endPointURL
    responseHandler:(HoundifyResponseCallback_deprecated __nullable)responseHandler;

- (void)dismissListeningViewControllerAnimated:(BOOL)animated
    completionHandler:(HoundifyCompletionHandler __nullable)completionHandler;


#pragma mark - Text Search

@property(nonatomic, assign, readonly) BOOL textSearchActive;

- (void)searchWithQuery:(NSString*)query
    requestInfo:(NSDictionary* __nullable)requestInfo
    endPointURL:(NSURL*)endPointURL
    completionHandler:(SoundHoundTextSearchCallback __nullable)handler;

- (void)cancelTextSearch;

@end

NS_ASSUME_NONNULL_END
