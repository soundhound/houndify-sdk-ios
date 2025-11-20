//
//  UITabBarController+HoundifySample.m
//  HoundifySDK Sample App (Objective-C)
//
//  Created by Jeff Weitzel on 7/12/17.
//  Copyright © 2017 SoundHound. All rights reserved.
//

#import "UITabBarController+HoundifySample.h"
#import "HoundifyViewController.h"
#import "VoiceSearchViewController.h"
#import "RawVoiceSearchViewController.h"

@implementation UITabBarController (HoundifySample)

- (void)disableAllVoiceSearchControllersExcept:(UIViewController *)exceptController
{
    NSArray *voiceSearchClasses = @[[HoundifyViewController class], [VoiceSearchViewController class], [RawVoiceSearchViewController class]];

    // First ensure everything is enabled.
    [self enableAllVoiceSearchControllers];

    // Disable other voice tabs during an active flow to avoid overlapping sessions.
    for (UIViewController *viewController in self.viewControllers) {
        if (viewController != exceptController && [voiceSearchClasses containsObject:[viewController class]]) {
            viewController.tabBarItem.enabled = NO;
        }
    }
}

- (void)enableAllVoiceSearchControllers
{
    NSArray *voiceSearchClasses = @[[HoundifyViewController class], [VoiceSearchViewController class], [RawVoiceSearchViewController class]];

    for (UIViewController *viewController in self.viewControllers) {
        if ([voiceSearchClasses containsObject:[viewController class]]) {
            viewController.tabBarItem.enabled = YES;
        }
    }
}

@end
