//
//  SceneDelegate.swift
//  yeltzland
//
//  Created by John Pollard on 10/07/2019.
//  Copyright © 2019 John Pollard. All rights reserved.
//

import UIKit
import SwiftUI

/// Scene delegate for the app
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    /// Main scene window
    var window: UIWindow?
    
    /// Called when a scene needs setting up
    /// - Parameters:
    ///   - scene: Scene connecting to
    ///   - session: Scene session
    ///   - connectionOptions: Connection options
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Make a main view hosting controller window
        let window = UIWindow(windowScene: windowScene)
        let mainViewController = MainViewHostingController<MainView>()
        
        let navController = UINavigationController()
        navController.viewControllers = [mainViewController]
        window.rootViewController = navController
        
        // Hode toolbar for Mac
        #if targetEnvironment(macCatalyst)
        if let titlebar = windowScene.titlebar {
            titlebar.titleVisibility = .hidden
            titlebar.toolbar = nil
        }
        #endif
        
        // Set window and make visible
        self.window = window
        window.makeKeyAndVisible()
    }
}
