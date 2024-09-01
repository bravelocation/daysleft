//
//  iCloudKeyValueDataProvider.swift
//  DaysLeft
//
//  Created by John Pollard on 20/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Foundation
import OSLog

/// Class that provides access to the iCloud key-value data
class CloudKeyValueDataProvider: DataProviderProtocol {
    
    /// Logger
    private let logger = Logger(subsystem: "com.bravelocation.daysleft.v2", category: "CloudKeyValueDataProvider")
    
    // MARK: - Properties
    
    /// User defaults
    private var appStandardUserDefaults: UserDefaults?
        
    // MARK: - Shared setup
    
    /// Static instance
    nonisolated(unsafe) private static let sharedInstance = CloudKeyValueDataProvider()
    
    /// Default instance of the class, used in most places
    /// As we register for update notifications, it doesn't make sense to allow multiple instances of the class running within the app
    static var `default`: CloudKeyValueDataProvider {
        return sharedInstance
    }
    
    // MARK: - Initialisation functions
    
    /// Default initialiser for the class
    ///
    /// - Parameters:
    ///     - defaultPreferencesName:The name of the plist file containing the default preferences
    ///     - suiteName: Name of the suite used to store the key value pair
    init(defaultPreferencesName: String = "DefaultPreferences", suiteName: String = "group.bravelocation.daysleft.v2") {

        // Setup the default preferences
        guard let defaultPrefsFile = Bundle.main.url(forResource: defaultPreferencesName, withExtension: "plist") else {
            self.logger.info("Can't find default preferences plist")
            return
        }
        
        guard let defaultPrefs = NSDictionary(contentsOf: defaultPrefsFile) as? [String: Any] else {
            self.logger.info("Can't load default preferences plist")
            return
        }
        
        // Don't use the suite on a Mac because of transfer issues on App Store Connect
        // May remove this if successfully transferred app
        #if targetEnvironment(macCatalyst)
            self.appStandardUserDefaults = UserDefaults.standard
        #else
            self.appStandardUserDefaults = UserDefaults(suiteName: suiteName)
        #endif
        
        self.appStandardUserDefaults?.register(defaults: defaultPrefs)
        
        self.initialiseiCloudSettings()
    }
 
    // MARK: - DataProviderProtocol methods
    
    /// Used to read an object setting from the user setting store
    ///
    /// - Parameter key: The key for the setting
    /// - Parameter defaultValue: Default value if not found
    /// - Returns: A value retrieved from the settings store
    func readObjectFromStore<T>(_ key: String, defaultValue: T) -> T {
        if let userSettingsValue = self.appStandardUserDefaults?.value(forKey: key) as? T {
            return userSettingsValue
        }
        
        return defaultValue
    }
    
    /// Used to write an Object setting to the user setting store (local and the cloud)
    ///
    /// - Parameters:
    ///     - value: The value for the setting
    ///     - key: The key for the setting
    func writeObjectToStore<T>(_ value: T, key: String) {
        // Then write to local user settings
        if let settings = self.appStandardUserDefaults {
            settings.set(value, forKey: key)
            settings.synchronize()
        } else {
            self.logger.debug("Couldn't get settings defaults")
        }
        
        // The write to iCloud store (if needed)
        self.writeSettingToiCloudStore(value, key: key)
        
        // Send a notification for the view controllers to refresh
        NotificationCenter.default.post(name: .AppSettingsUpdated, object: nil)
    }
    
    /// Synchronises data with the remote data store
    func synchronise() {
        let store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default
        store.synchronize()
    }
    
    // MARK: - iCloud functions
    
    /// Initialises the listeners to key-value store changes
    private func initialiseiCloudSettings() {
        self.logger.debug("Initialising iCloud Settings")
        let store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CloudKeyValueDataProvider.updateKVStoreItems(_:)),
                                               name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: store)
        store.synchronize()
    }
    
    /// Writes a setting to the key-value store
    /// - Parameters:
    ///   - value: Value to write
    ///   - key: Key to write
    private func writeSettingToiCloudStore<T>(_ value: T, key: String) {
        let store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default
        store.set(value, forKey: key)
        store.synchronize()
    }
    
    /// Used in the selector to handle incoming notifications of changes from the cloud
    ///
    /// - Parameter notification: The incoming notification
    @objc
    private func updateKVStoreItems(_ notification: Notification) {
        self.logger.debug("Detected iCloud key-value storage change")
        
        // Assuming we have a valid reason for the change
        if let downcastedReason = notification.userInfo?[NSUbiquitousKeyValueStoreChangeReasonKey] as? NSNumber {
            
            let reason = downcastedReason.intValue
            
            if reason == NSUbiquitousKeyValueStoreServerChange || reason == NSUbiquitousKeyValueStoreInitialSyncChange {
                
                // If something is changing externally, get the changes and update the corresponding keys locally.
                guard let changedKeys = notification.userInfo?[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] else {
                    self.logger.debug("No changed keys")
                    return
                }
                
                let store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default
                
                // This loop assumes you are using the same key names in both the user defaults database and the iCloud key-value store
                for key: String in changedKeys {
                    if let settingValue = store.object(forKey: key) {
                        self.writeObjectToStore(settingValue, key: key)
                    }
                }
                
                store.synchronize()
                
                // Finally send a notification for the view controllers to refresh
                NotificationCenter.default.post(name: .AppSettingsUpdated, object: nil)
                self.logger.debug("Sent notification for iCloud change")
            }
        } else {
            self.logger.debug("Unknown iCloud KV reason for change")
        }
    }
}
