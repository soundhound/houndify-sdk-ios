//
//  UITabBarController+additions.swift
//  HoundifySDK Sample App (Swift)
//
//  Created by Jeff Weitzel on 6/30/17.
//  Copyright © 2017 SoundHound. All rights reserved.
//

import UIKit

extension UITabBarController {
    func disableAllVoiceSearchControllers(except exceptController: UIViewController) {
        let voiceSearchControllerTypes = [HoundifyViewController.self, VoiceSearchViewController.self, RawVoiceSearchViewController.self]
        
        viewControllers?.forEach { viewController in
            if viewController != exceptController && voiceSearchControllerTypes.contains { type(of:viewController).self == $0 } {
                viewController.tabBarItem.isEnabled = false
            }
        }
    }
}
