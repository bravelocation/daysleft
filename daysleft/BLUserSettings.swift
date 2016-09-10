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
    public var watchSessionInitialised: Bool = false
    
    /// Default initialiser for the class
    ///
    /// param: defaultPreferencesName The name of the plist file containing the default preferences
    public init(defaultPreferencesName: String = "DefaultPreferences", suiteName: String = "group.bravelocation.daysleft") {
        
        // Need to inherit from NSObject, so call super.init()
        super.init()
        
        // Setup the default preferences
        let defaultPrefsFile: NSURL? = NSBundle.mainBundle().URLForResource(defaultPreferencesName, withExtension: "plist")
        let defaultPrefs: NSDictionary? = NSDictionary(contentsOfURL:defaultPrefsFile!)
        
        self.appStandardUserDefaults = NSUserDefaults(suiteName: suiteName)!
        self.appStandardUserDefaults!.registerDefaults(defaultPrefs as! [String: AnyObject]);
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
        
        // Then write to local user settings
        if let settings = self.appStandardUserDefaults {
            settings.setObject(value, forKey:key)
            settings.synchronize()
        } else {
            NSLog("Couldn't get settings defaults")
        }
    }
    
    
    public func initialiseWatchSession() {
        if (self.watchSessionInitialised) {
            NSLog("Watch session already initialised")
            return
        } else {
            self.watchSessionInitialised = true
            NSLog("Watch session starting initialisation...")
        }
        
        // Set up watch setting if appropriate
        if (WCSession.isSupported()) {
            NSLog("Setting up watch session")
            let session: WCSession = WCSession.defaultSession();
            session.delegate = self
            session.activateSession()
            NSLog("Watch session activated")
        } else {
            NSLog("No watch session set up")
        }
    }
    
    /// WCSessionDelegate implementation - update local settings when transfered from phone
    @objc
    public func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        NSLog("New user info transfer data received on watch")

        for (key, value) in userInfo {
            self.writeObjectToStore(value, key: key)
        }
        
        // Finally send a notification for the view controllers to refresh
        NSNotificationCenter.defaultCenter().postNotificationName(BLUserSettings.UpdateSettingsNotification, object:nil, userInfo:nil)
        NSLog("Sent UpdateSettingsNotification")
    }
    
    @objc
    public func session(session: WCSession, didReceiveUpdate receivedApplicationContext: [String : AnyObject]) {
        NSLog("New context transfer data received on watch")
        
        for (key, value) in receivedApplicationContext {
            self.writeObjectToStore(value, key: key)
        }
                
        // Finally send a notification for the view controllers to refresh
        NSNotificationCenter.defaultCenter().postNotificationName(DaysLeftModel.UpdateSettingsNotification, object:nil, userInfo:nil)
        NSLog("Sent UpdateSettingsNotification")
    }
    
    @objc
    public func session(session: WCSession,
                          activationDidCompleteWithState activationState: WCSessionActivationState,
                                                         error: NSError?) {}
    
    @objc
    public func sessionDidBecomeInactive(session: WCSession) {}
    
    @objc
    public func sessionDidDeactivate(session: WCSession) {}
}
