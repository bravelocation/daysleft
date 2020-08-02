//
//  SceneDelegate.swift
//  yeltzland
//
//  Created by John Pollard on 10/07/2019.
//  Copyright © 2019 John Pollard. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        #if targetEnvironment(macCatalyst)
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        if let titlebar = windowScene.titlebar {
            titlebar.titleVisibility = .hidden
            titlebar.toolbar = nil
        }
        #endif
    }

    @available(iOS 13.0, *)
    func sceneDidDisconnect(_ scene: UIScene) {
    }

    @available(iOS 13.0, *)
    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    @available(iOS 13.0, *)
    func sceneWillResignActive(_ scene: UIScene) {
    }

    @available(iOS 13.0, *)
    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    @available(iOS 13.0, *)
    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
