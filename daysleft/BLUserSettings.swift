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
    
    public init(defaultPreferencesName: String) {
        // Setup the default preferences
        let defaultPrefsFile: NSURL? = NSBundle.mainBundle().URLForResource(defaultPreferencesName, withExtension: "plist")
        let defaultPrefs: NSDictionary? = NSDictionary(contentsOfURL:defaultPrefsFile!)
        
        self.appStandardUserDefaults = NSUserDefaults()
        self.appStandardUserDefaults.registerDefaults(defaultPrefs as! [NSObject : AnyObject]);
        
        // Setup the iCloud store
        var store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.defaultStore()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateKVStoreItems", name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification, object: store)
        
        store.synchronize()
    }
    
    public convenience init() {
        self.init(defaultPreferencesName: "DefaultPreferences")
    }
 
    public func readObjectFromStore(key: String) -> AnyObject?{
        return self.appStandardUserDefaults.valueForKey(key)
    }

    public func writeIntegerToStore(value: Int, key: String) {
        // First write to local store
        self.appStandardUserDefaults.setInteger(value, forKey: key)
        self.appStandardUserDefaults.synchronize()
        
        // Then write to iCloud key-value store
        let store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.defaultStore()
        store.setLongLong(Int64(value), forKey: key)
        store.synchronize()
    }
    
    public func writeBoolToStore(value: Bool, key: String) {
        // First write to local store
        self.appStandardUserDefaults.setBool(value, forKey: key)
        self.appStandardUserDefaults.synchronize()
        
        // Then write to iCloud key-value store
        let store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.defaultStore()
        store.setBool(value, forKey: key)
        store.synchronize()
    }
    
    public func writeObjectToStore(value: AnyObject, key: String) {
        // First write to local store
        self.appStandardUserDefaults.setObject(value, forKey: key)
        self.appStandardUserDefaults.synchronize()
        
        // Then write to iCloud key-value store
        let store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.defaultStore()
        store.setObject(value, forKey: key)
        store.synchronize()
    }
    
    public func updateKVStoreItems(notification: NSNotification) {
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
                    self.appStandardUserDefaults.setObject(settingValue, forKey: key)
                    NSLog("Updated local setting for %@", key)
                }
            }
        } else {
            NSLog("Unknown iCloud KV reason for change")
        }
    }
}
