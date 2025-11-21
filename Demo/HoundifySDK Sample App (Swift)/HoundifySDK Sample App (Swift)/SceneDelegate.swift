//
//  SceneDelegate.swift
//  HoundifySDK Sample App (Swift)
//
//  Handles window lifecycle for UIScene-based apps.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        // Storyboard-based apps get the window from the storyboard; ensure it’s attached to this scene.
        window?.windowScene = windowScene
    }
}
