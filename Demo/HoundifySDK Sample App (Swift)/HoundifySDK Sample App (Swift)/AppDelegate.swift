//
//  AppDelegate.swift
//  HoundifySDK Sample App (Swift)
//
//  Created by Jeff Weitzel on 6/29/17.
//  Copyright © 2017 SoundHound. All rights reserved.
//

import UIKit
import HoundifySDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        /* ATTENTION: Obtain a Client ID and Key from https://www.houndify.com/ Insert them below. Then delete this line. */ throw NSError()
        
        Hound.setClientID(<#T##clientID: String##String#>)
        Hound.setClientKey(<#T##clientKey: String##String#>)
        
        return true
    }


}

