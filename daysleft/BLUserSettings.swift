//
//  BLUserSettings.swift
//  daysleft
//
//  Created by John Pollard on 16/02/2015.
//  Copyright (c) 2015 Brave Location Software. All rights reserved.
//

import Foundation
import WatchConnectivity

public class BLUserSettings: NSObject, WCSessionDelegate {

    public static let UpdateSettingsNotification = "kBLUserSettingsNotification"
    private var appStandardUserDefaults: NSUserDefaults?
    private var onWatch: Bool = false
    
    /// Default initialiser for the class
    ///
    /// param: defaultPreferencesName The name of the plist file containing the default preferences
    public init(defaultPreferencesName: String = "DefaultPreferences", suiteName: String = "group.bravelocation.daysleft", onWatch: Bool = false) {
        
        // Now we inherit from NSObject, call base class constructor
        super.init()
        self.onWatch = onWatch;
        
        // Setup the default preferences
        let defaultPrefsFile: NSURL? = NSBundle.mainBundle().URLForResource(defaultPreferencesName, withExtension: "plist")
        let defaultPrefs: NSDictionary? = NSDictionary(contentsOfURL:defaultPrefsFile!)
        
        self.appStandardUserDefaults = NSUserDefaults(suiteName: suiteName)!
        self.appStandardUserDefaults!.registerDefaults(defaultPrefs as! [String: AnyObject]);
        
        // Set up watch setting if appropriate
        if (WCSession.isSupported()) {
            NSLog("Setting up watch session")
            let session: WCSession = WCSession.defaultSession();
            session.delegate = self
            session.activateSession()
        } else {
            NSLog("No watch session set up")
        }
        
        // Setup the iCloud store if not on watch
        if (!self.onWatch) {
            let store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.defaultStore()
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateKVStoreItems:", name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification, object: store)
            store.synchronize()
        } else {
            NSLog("On watch: Not setup iCloud settings")
        }
        
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
        return self.appStandardUserDefaults!.valueForKey(key)
    }
    
    /// Used to write an Integer setting to the user setting store (local and the cloud)
    ///
    /// param: value The value for the setting
    /// param: key The key for the setting
    public func writeIntegerToStore(value: Int, key: String) {
        // First write to local store
        self.appStandardUserDefaults!.setInteger(value, forKey: key)
        self.appStandardUserDefaults!.synchronize()
        
        // Then write to iCloud key-value store
        if (!self.onWatch) {
            let store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.defaultStore()
            store.setLongLong(Int64(value), forKey: key)
            store.synchronize()
            self.updateWatchSettings(key)
        }
    }
    
    /// Used to write an Boolean setting to the user setting store (local and the cloud)
    ///
    /// param: value The value for the setting
    /// param: key The key for the setting
    public func writeBoolToStore(value: Bool, key: String) {
        // First write to local store
        self.appStandardUserDefaults!.setBool(value, forKey: key)
        self.appStandardUserDefaults!.synchronize()
        
        // Then write to iCloud key-value store
        if (!self.onWatch) {
            let store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.defaultStore()
            store.setBool(value, forKey: key)
            store.synchronize()
            self.updateWatchSettings(key)
        }
    }
    
    /// Used to write an Object setting to the user setting store (local and the cloud)
    ///
    /// param: value The value for the setting
    /// param: key The key for the setting
    public func writeObjectToStore(value: AnyObject, key: String) {
        // First write to local store
        self.appStandardUserDefaults!.setObject(value, forKey: key)
        self.appStandardUserDefaults!.synchronize()
        
        // Then write to iCloud key-value store
        if (!self.onWatch) {
            let store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.defaultStore()
            store.setObject(value, forKey: key)
            store.synchronize()
            self.updateWatchSettings(key)
        }
    }
    
    /// WCSessionDelegate implementation - update local settings when transfered from phone
    public func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        NSLog("New user info transfer data received on watch")
        for (key, value) in userInfo {
            self.appStandardUserDefaults!.setObject(value, forKey: key)
            NSLog("Received setting update for %@", key)
        }

        self.appStandardUserDefaults!.synchronize()
        
        NSNotificationCenter.defaultCenter().postNotificationName(BLUserSettings.UpdateSettingsNotification, object:nil, userInfo:nil)
        NSLog("Sent BLUserSettingsUpdated notification")
    }
    
    /// Send updated settings to watch
    public func updateWatchSettings(key : String) {
        if (!self.onWatch && WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            
            var updatedSettings = Dictionary<String, AnyObject>()
            updatedSettings[key] = self.appStandardUserDefaults!.valueForKey(key)
            
            session.transferUserInfo(updatedSettings)
            NSLog("Sent settings for %@ to watch", key)
        }
    }
    
    /// Used in the selector to handle incoming notifications of changes from the cloud
    ///
    /// param: notification The incoming notification
    @objc
    private func updateKVStoreItems(notification: NSNotification) {
        if (self.onWatch) {
            return;
        }
        
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
            
                // This loop assumes you are using the same key names in both the user defaults database and the iCloud key-value store
                for key:String in changedKeys {
                    let settingValue: AnyObject? = store.objectForKey(key)
                    self.appStandardUserDefaults!.setObject(settingValue, forKey: key)
                    NSLog("Updated local setting for %@", key)
                }
            }
        } else {
            NSLog("Unknown iCloud KV reason for change")
        }
    }
}
