//
//  UITabBarController+HoundifySample.h
//  HoundifySDK Sample App (Objective-C)
//
//  Created by Jeff Weitzel on 7/12/17.
//  Copyright © 2017 SoundHound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBarController (HoundifySample)

- (void)disableAllVoiceSearchControllersExcept:(UIViewController *)exceptController;
- (void)enableAllVoiceSearchControllers;

@end
