//
//  SceneDelegate.m
//  HoundifySDK Sample App (Objective-C)
//

#import "SceneDelegate.h"

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions
{
    if (![scene isKindOfClass:[UIWindowScene class]]) {
        return;
    }
    
    self.window.windowScene = (UIWindowScene *)scene;
}

@end
