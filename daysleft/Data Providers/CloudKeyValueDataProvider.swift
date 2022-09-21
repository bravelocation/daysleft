//
//  iCloudKeyValueDataProvider.swift
//  DaysLeft
//
//  Created by John Pollard on 20/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Foundation

class CloudKeyValueDataProvider: DataProviderProtocol {
    // MARK: - Properties
    
    /// User defaults
    private var appStandardUserDefaults: UserDefaults?
    
    /// Settings cache used to store settings locally for faster access
    private var settingsCache = Dictionary<String, Any>()
    
    // MARK: - Shared setup
    private static let sharedInstance = CloudKeyValueDataProvider()
                                    
    static var `default`: CloudKeyValueDataProvider {
        get {
            return sharedInstance
        }
    }
    
    // MARK: - Initialisation functions
    
    /// Default initialiser for the class
    ///
    /// param: defaultPreferencesName The name of the plist file containing the default preferences
    init(defaultPreferencesName: String = "DefaultPreferences", suiteName: String = "group.bravelocation.daysleft") {

        // Setup the default preferences
        guard let defaultPrefsFile = Bundle.main.url(forResource: defaultPreferencesName, withExtension: "plist") else {
            print("Can't find default preferences plist")
            return
        }
        
        guard let defaultPrefs = NSDictionary(contentsOf: defaultPrefsFile) else {
            print("Can't load default preferences plist")
            return
        }
        
        self.appStandardUserDefaults = UserDefaults(suiteName: suiteName)
        self.appStandardUserDefaults?.register(defaults: defaultPrefs as! [String: AnyObject])
        
        // Preload cache
        print("Preloading settings cache...")
        self.settingsCache["start"] = self.appStandardUserDefaults!.value(forKey: "start")
        self.settingsCache["end"] = self.appStandardUserDefaults!.value(forKey: "end")
        self.settingsCache["title"] = self.appStandardUserDefaults!.value(forKey: "title")
        self.settingsCache["weekdaysOnly"] = self.appStandardUserDefaults!.value(forKey: "weekdaysOnly")
        
        self.initialiseiCloudSettings()
    }
 
    /// Used to read an object setting from the user setting store
    ///
    /// param: key The key for the setting
    /// returns: An AnyObject? value retrieved from the settings store
    func readObjectFromStore(_ key: String) -> Any? {
        // First try the local cache
        let cachedValue = self.settingsCache[key]
        
        if (cachedValue != nil) {
            return cachedValue
        }
        
        // Otherwise try the user details
        let userSettingsValue = self.appStandardUserDefaults!.value(forKey: key)
        if (userSettingsValue != nil) {
            self.settingsCache[key] = userSettingsValue as AnyObject?
        }
        
        return userSettingsValue as AnyObject?
    }
    
    /// Used to write an Object setting to the user setting store (local and the cloud)
    ///
    /// param: value The value for the setting
    /// param: key The key for the setting
    func writeObjectToStore(_ value: AnyObject, key: String) {
        // First write to local store
        self.settingsCache[key] = value
        
        // Then write to local user settings
        if let settings = self.appStandardUserDefaults {
            settings.set(value, forKey: key)
            settings.synchronize()
        } else {
            print("Couldn't get settings defaults")
        }
        
        // The write to iCloud store (if needed)
        self.writeSettingToiCloudStore(value, key: key)
    }
    
    // MARK: - iCloud functions
    
    /// Send updated settings to watch
    private func initialiseiCloudSettings() {
        print("Initialising iCloud Settings")
        let store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CloudKeyValueDataProvider.updateKVStoreItems(_:)),
                                               name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: store)
        store.synchronize()
    }
    
    private func writeSettingToiCloudStore(_ value: AnyObject, key: String) {
        let store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default
        store.set(value, forKey: key)
        store.synchronize()
    }
    
    /// Used in the selector to handle incoming notifications of changes from the cloud
    ///
    /// param: notification The incoming notification
    @objc
    private func updateKVStoreItems(_ notification: Notification) {
        print("Detected iCloud key-value storage change")
        
        // Get the list of keys that changed
        let userInfo = notification.userInfo! as NSDictionary
        let reasonForChange = userInfo.object(forKey: NSUbiquitousKeyValueStoreChangeReasonKey) as AnyObject?
        
        // Assuming we have a valid reason for the change
        if let downcastedReason = reasonForChange as? NSNumber {
            let reason: NSInteger = downcastedReason.intValue
            if ((reason == NSUbiquitousKeyValueStoreServerChange) || (reason == NSUbiquitousKeyValueStoreInitialSyncChange)) {
                // If something is changing externally, get the changes and update the corresponding keys locally.
                let changedKeys = userInfo.object(forKey: NSUbiquitousKeyValueStoreChangedKeysKey) as! [String]
                let store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default
                
                // This loop assumes you are using the same key names in both the user defaults database and the iCloud key-value store
                for key: String in changedKeys {
                    let settingValue: AnyObject? = store.object(forKey: key) as AnyObject?
                    self.writeObjectToStore(settingValue!, key: key)
                }
                
                store.synchronize()
                
                // Finally send a notification for the view controllers to refresh
                NotificationCenter.default.post(name: .AppSettingsUpdated, object: nil)
                print("Sent notification for iCloud change")
            }
        } else {
            print("Unknown iCloud KV reason for change")
        }
    }
}
