//
//  AppDelegate.m
//  HoundifySDK Sample App (Objective-C)
//
//  Created by Jeff Weitzel on 7/12/17.
//  Copyright © 2017 SoundHound. All rights reserved.
//

#import "AppDelegate.h"
#import "SceneDelegate.h"
@import HoundifySDK;

#pragma mark - AppDelegate

@interface AppDelegate()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    
#error Obtain a Client ID and Key from https://www.houndify.com/ Insert them below. Then delete this line.

//    [Hound setClientID:<CLIENT-ID>];
//    [Hound setClientKey:<CLIENT-KEY];
    
    return YES;
}

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options
{
    UISceneConfiguration *configuration = [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
    configuration.delegateClass = [SceneDelegate class];
    configuration.storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return configuration;
}

@end
