//
//  FirebaseRemoteConfig.swift
//  DaysLeft
//
//  Created by John Pollard on 16/05/2024.
//  Copyright © 2024 Brave Location Software. All rights reserved.
//

import FirebaseRemoteConfig
import SwiftUI
import OSLog

class RemoteConfigManager: ObservableObject {
    private var remoteConfig: RemoteConfig
    
    @Published var bundleId: String?
    @Published var message: String?
    @Published var newAppId: String?
    @Published var showMessage: Bool = false
    
    /// Static instance of the class
    private static let sharedInstance = RemoteConfigManager()
    
    /// Shared static instance of the class, to make it easy to access across the app
    class var shared: RemoteConfigManager {
        return sharedInstance
    }
    
    private let logger = Logger(subsystem: "com.bravelocation.daysleft", category: "RemoteConfigManager")
    
    private init() {
        remoteConfig = RemoteConfig.remoteConfig()
        
        // Add the settings
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        
        // Load the default settings
        remoteConfig.setDefaults(fromPlist: "remote_config_defaults")
        
        // Fetch the latest settings
        fetchInitialSettings()
        
        // Setup listener for changes
        remoteConfig.addOnConfigUpdateListener { configUpdate, error in
          self.remoteConfig.activate { changed, error in
              self.updateValues()
          }
        }
    }
    
    func openInAppStore() {
        guard let appId = self.newAppId else { return }
        
        let appStoreLink = "https://itunes.apple.com/app/id" + appId + "?mt=8&at=1001ln7z"
        let appStoreUrl = URL(string: appStoreLink)
        
        self.logger.debug("Opening App Store link: \(appStoreLink)")
        UIApplication.shared.open(appStoreUrl!)
    }
    
    private func fetchInitialSettings() {
        remoteConfig.fetch { (status, error) -> Void in
          if status == .success {
              self.logger.debug("Config fetched!")
              self.remoteConfig.activate { changed, error in
                  self.updateValues()
              }
          } else {
              self.logger.debug("Config not fetched")
              self.logger.debug("Error: \(error?.localizedDescription ?? "No error available.")")
          }
        }
    }
    
    private func updateValues() {
        DispatchQueue.main.async {
            self.bundleId = self.remoteConfig["bundle_id"].stringValue
            self.message = self.remoteConfig["message"].stringValue
            self.newAppId = self.remoteConfig["new_app_id"].stringValue
            
            // Show the message if bundleID matches the current bundle ID
            self.showMessage = (self.bundleId == Bundle.main.bundleIdentifier)
        }
    }
}
