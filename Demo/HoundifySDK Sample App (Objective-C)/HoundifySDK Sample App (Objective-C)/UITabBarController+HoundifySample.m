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

    // If an active voice flow needs to lock other voice tabs, disable only while that flow runs.
    for (UIViewController *viewController in self.viewControllers) {
        if (viewController != exceptController && [voiceSearchClasses containsObject:[viewController class]]) {
            viewController.tabBarItem.enabled = NO;
        }
    }
}

@end
