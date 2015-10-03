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
    public var appStandardUserDefaults: NSUserDefaults?
    public var settingsCache = Dictionary<String, AnyObject>()
    
    /// Default initialiser for the class
    ///
    /// param: defaultPreferencesName The name of the plist file containing the default preferences
    public init(defaultPreferencesName: String = "DefaultPreferences", suiteName: String = "group.bravelocation.daysleft") {
        
        // Now we inherit from NSObject, call base class constructor
        super.init()
        
        // Setup the default preferences
        let defaultPrefsFile: NSURL? = NSBundle.mainBundle().URLForResource(defaultPreferencesName, withExtension: "plist")
        let defaultPrefs: NSDictionary? = NSDictionary(contentsOfURL:defaultPrefsFile!)
        
        self.appStandardUserDefaults = NSUserDefaults(suiteName: suiteName)!
        self.appStandardUserDefaults!.registerDefaults(defaultPrefs as! [String: AnyObject]);
        
        // Set up watch setting if appropriate
        if (WCSession.isSupported()) {
            print("Setting up watch session")
            let session: WCSession = WCSession.defaultSession();
            session.delegate = self
            session.activateSession()
        } else {
            print("No watch session set up")
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
        // First try the local cache
        let cachedValue = self.settingsCache[key]
        
        if (cachedValue != nil) {
            return cachedValue;
        }
        
        // Otherwise try the user details
        let userSettingsValue = self.appStandardUserDefaults!.valueForKey(key)
        if (userSettingsValue != nil) {
            print("Updating settings cache for \(key)")
            self.settingsCache[key] = userSettingsValue
        }
        
        return userSettingsValue
    }
    
    /// Used to write an Object setting to the user setting store (local and the cloud)
    ///
    /// param: value The value for the setting
    /// param: key The key for the setting
    public func writeObjectToStore(value: AnyObject, key: String) {
        // First write to local store
        self.settingsCache[key] = value
        print("Updated \(key) in local settings cache");
        
        // Then write to local user settings
        self.appStandardUserDefaults!.setObject(value, forKey:key)
        self.appStandardUserDefaults!.synchronize()
    }
    
    /// WCSessionDelegate implementation - update local settings when transfered from phone
    public func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        print("New user info transfer data received on watch")
        for (key, value) in userInfo {
            self.writeObjectToStore(value, key: key)
            print("Received setting update for \(key)")
        }

        self.appStandardUserDefaults!.synchronize()

        // Finally send a notification for the view controllers to refresh
        NSNotificationCenter.defaultCenter().postNotificationName(BLUserSettings.UpdateSettingsNotification, object:nil, userInfo:nil)
        print("Sent UpdateSettingsNotification")
    }
}
