//
//  BLUserSettings.swift
//  daysleft
//
//  Created by John Pollard on 16/02/2015.
//  Copyright (c) 2015 Brave Location Software. All rights reserved.
//

import Foundation

public class BLUserSettings {

    private var appStandardUserDefaults: NSUserDefaults
    
    /// Default initialiser for the class
    ///
    /// param: defaultPreferencesName The name of the plist file containing the default preferences
    public init(defaultPreferencesName: String, suiteName: String) {
        // Setup the default preferences
        let defaultPrefsFile: NSURL? = NSBundle.mainBundle().URLForResource(defaultPreferencesName, withExtension: "plist")
        let defaultPrefs: NSDictionary? = NSDictionary(contentsOfURL:defaultPrefsFile!)
        
        self.appStandardUserDefaults = NSUserDefaults(suiteName: suiteName)!
        self.appStandardUserDefaults.registerDefaults(defaultPrefs as! [String: AnyObject]);
        
        // Setup the iCloud store
        let store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.defaultStore()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateKVStoreItems:", name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification, object: store)
        
        store.synchronize()
    }
    
    /// Convenience constructor using the value "DefaultPreferences" for the plist file
    public convenience init() {
        self.init(defaultPreferencesName: "DefaultPreferences", suiteName: "group.bravelocation.daysleft")
    }
    
    /// Destructor
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
 
    /// Used to read an object setting from the user setting store
    ///
    /// param: key The key for the setting
    /// returns: An AnyObject? value retrieved from the settings store
    public func readObjectFromStore(key: String) -> AnyObject?{
        return self.appStandardUserDefaults.valueForKey(key)
    }
    
    /// Used to write an Integer setting to the user setting store (local and the cloud)
    ///
    /// param: value The value for the setting
    /// param: key The key for the setting
    public func writeIntegerToStore(value: Int, key: String) {
        // First write to local store
        self.appStandardUserDefaults.setInteger(value, forKey: key)
        self.appStandardUserDefaults.synchronize()
        
        // Then write to iCloud key-value store
        let store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.defaultStore()
        store.setLongLong(Int64(value), forKey: key)
        store.synchronize()
    }
    
    /// Used to write an Boolean setting to the user setting store (local and the cloud)
    ///
    /// param: value The value for the setting
    /// param: key The key for the setting
    public func writeBoolToStore(value: Bool, key: String) {
        // First write to local store
        self.appStandardUserDefaults.setBool(value, forKey: key)
        self.appStandardUserDefaults.synchronize()
        
        // Then write to iCloud key-value store
        let store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.defaultStore()
        store.setBool(value, forKey: key)
        store.synchronize()
    }
    
    /// Used to write an Object setting to the user setting store (local and the cloud)
    ///
    /// param: value The value for the setting
    /// param: key The key for the setting
    public func writeObjectToStore(value: AnyObject, key: String) {
        // First write to local store
        self.appStandardUserDefaults.setObject(value, forKey: key)
        self.appStandardUserDefaults.synchronize()
        
        // Then write to iCloud key-value store
        let store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.defaultStore()
        store.setObject(value, forKey: key)
        store.synchronize()
    }
    
    /// Used in the selector to handle incoming notifications of changes from the cloud
    ///
    /// param: notification The incoming notification
    @objc
    private func updateKVStoreItems(notification: NSNotification) {
        NSLog("Detected iCloud key-value storage change")
        
        // Get the list of keys that changed
        let userInfo: NSDictionary = notification.userInfo!
        let reasonForChange: AnyObject? = userInfo.objectForKey(NSUbiquitousKeyValueStoreChangeReasonKey)
        
        // Assuming we have a valid reason for the change
        if let downcastedReason = reasonForChange as? NSNumber {
            let reason: NSInteger = downcastedReason.integerValue
            if ((reason == NSUbiquitousKeyValueStoreServerChange) || (reason == NSUbiquitousKeyValueStoreInitialSyncChange)) {
                // If something is changing externally, get the changes and update the corresponding keys locally.
                let changedKeys = userInfo.objectForKey(NSUbiquitousKeyValueStoreChangedKeysKey) as! [String]
                let store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.defaultStore();
                let userDefaults = self.appStandardUserDefaults
            
                // This loop assumes you are using the same key names in both the user defaults database and the iCloud key-value store
                for key:String in changedKeys {
                    let settingValue: AnyObject? = store.objectForKey(key)
                    userDefaults.setObject(settingValue, forKey: key)
                    NSLog("Updated local setting for %@", key)
                }
            }
        } else {
            NSLog("Unknown iCloud KV reason for change")
        }
    }
}
