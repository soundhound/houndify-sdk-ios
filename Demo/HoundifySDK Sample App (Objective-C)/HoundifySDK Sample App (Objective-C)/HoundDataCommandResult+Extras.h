//
//  HoundDataCommandResult+Extras.h
//  HoundifySDK Sample App (Objective-C)
//
//  Created by Jeff Weitzel on 4/25/19.
//  Copyright © 2019 SoundHound. All rights reserved.
//

#import <HoundifySDK/HoundifySDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface HoundDataCommandResult (Extras)

- (NSAttributedString  * _Nullable )exampleResultText;
@property (nonatomic, readonly) BOOL isClientClearScreenCommand;

@end

NS_ASSUME_NONNULL_END
