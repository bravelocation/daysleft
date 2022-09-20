//
//  AppDaysLeftModel.swift
//  daysleft
//
//  Created by John Pollard on 03/11/2017.
//  Copyright © 2017 Brave Location Software. All rights reserved.
//

import UIKit

class AppDaysLeftModel: DaysLeftModel {

    public static let iCloudSettingsNotification = "kBLiCloudSettingsNotification"

    /// Send updated settings to watch
    open override func initialiseiCloudSettings() {
        print("Initialising iCloud Settings")
        let store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default
        NotificationCenter.default.addObserver(self, selector: #selector(AppDaysLeftModel.updateKVStoreItems(_:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: store)
        store.synchronize()
    }
    
    open override func writeSettingToiCloudStore(_ value: AnyObject, key: String) {
        let store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default
        store.set(value, forKey: key)
        store.synchronize()
    }
    
    /// Used in the selector to handle incoming notifications of changes from the cloud
    ///
    /// param: notification The incoming notification
    @objc
    fileprivate func updateKVStoreItems(_ notification: Notification) {
        print("Detected iCloud key-value storage change")
        
        // Get the list of keys that changed
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let reasonForChange: AnyObject? = userInfo.object(forKey: NSUbiquitousKeyValueStoreChangeReasonKey) as AnyObject?
        
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
                NotificationCenter.default.post(name: Notification.Name(rawValue: AppDaysLeftModel.iCloudSettingsNotification), object: nil, userInfo: nil)
                print("Sent notification for iCloud change")
            }
        } else {
            print("Unknown iCloud KV reason for change")
        }
    }
}
