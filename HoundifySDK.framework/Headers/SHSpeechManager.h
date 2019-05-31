//
//  SHSpeechManager.h
//  SHHound
//
//  Created by Cyril Austin on 2/12/15.
//  Copyright (c) 2015 SoundHound. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Notifications

extern NSString* SHSpeechManagerDidFinishSpeakingNotification;

#pragma mark - Callbacks

typedef void (^SHSpeechManagerStartCallback)(BOOL started);

#pragma mark - SHSpeechManager


@interface SHSpeechManager : NSObject

+ (instancetype)instance;

- (void)reset;

- (BOOL)supportsLanguage:(NSString*)language;

- (void)speak:(NSString*)text;
- (void)speak:(NSString*)text completion:(dispatch_block_t _Nullable)completion;

// normalSpeed is deprecated. You'll get normal speed for those method no matter what you put in.
- (void)speak:(NSString*)text language:(NSString* _Nullable)language normalSpeed:(BOOL)normalSpeed;
- (void)speak:(NSString*)text language:(NSString* _Nullable)language normalSpeed:(BOOL)normalSpeed completion:(dispatch_block_t _Nullable)completion;
- (void)speak:(NSString*)text language:(NSString* _Nullable)language speed:(double)speed completion:(dispatch_block_t _Nullable)completion;

- (void)stopSpeaking;

- (BOOL)isSpeaking;

@end

NS_ASSUME_NONNULL_END
