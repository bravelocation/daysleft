//
//  BLUserSettings.swift
//  daysleft
//
//  Created by John Pollard on 16/02/2015.
//  Copyright (c) 2015 Brave Location Software. All rights reserved.
//

import Foundation
import WatchConnectivity

class BLUserSettings: NSObject, WCSessionDelegate {

    public static let UpdateSettingsNotification = "kBLUserSettingsNotification"
    var appStandardUserDefaults: UserDefaults?
    var settingsCache = Dictionary<String, Any>()
    var watchSessionInitialised: Bool = false
    
    /// Default initialiser for the class
    ///
    /// param: defaultPreferencesName The name of the plist file containing the default preferences
    public init(defaultPreferencesName: String = "DefaultPreferences", suiteName: String = "group.bravelocation.daysleft") {
        
        // Need to inherit from NSObject, so call super.init()
        super.init()
        
        // Setup the default preferences
        let defaultPrefsFile: URL? = Bundle.main.url(forResource: defaultPreferencesName, withExtension: "plist")
        let defaultPrefs: NSDictionary? = NSDictionary(contentsOf: defaultPrefsFile!)
        
        self.appStandardUserDefaults = UserDefaults(suiteName: suiteName)!
        self.appStandardUserDefaults!.register(defaults: defaultPrefs as! [String: AnyObject])
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
    }
    
    func initialiseWatchSession() {
        if (self.watchSessionInitialised) {
            print("Watch session already initialised")
            return
        } else {
            self.watchSessionInitialised = true
            print("Watch session starting initialisation...")
        }
        
        // Set up watch setting if appropriate
        if (WCSession.isSupported()) {
            print("Setting up watch session")
            let session: WCSession = WCSession.default
            session.delegate = self
            session.activate()
            print("Watch session activated")
        } else {
            print("No watch session set up")
        }
    }
    
    /// WCSessionDelegate implementation - update local settings when transfered from phone
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        print("New user info transfer data received on watch")
        
        for (key, value) in userInfo {
            self.writeObjectToStore(value as AnyObject, key: key)
        }
        
        // Finally send a notification for the view controllers to refresh
        NotificationCenter.default.post(name: Notification.Name(rawValue: BLUserSettings.UpdateSettingsNotification), object: nil, userInfo: nil)
        print("Sent UpdateSettingsNotification")
    }
    
    @nonobjc func session(_ session: WCSession, didReceiveUpdate receivedApplicationContext: [String: AnyObject]) {
        print("New context transfer data received on watch")
        
        for (key, value) in receivedApplicationContext {
            self.writeObjectToStore(value, key: key)
        }
        
        // Finally send a notification for the view controllers to refresh
        NotificationCenter.default.post(name: Notification.Name(rawValue: DaysLeftModel.UpdateSettingsNotification), object: nil, userInfo: nil)
        print("Sent UpdateSettingsNotification")
    }
    
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {}
    
    #if os(iOS)
    public func sessionDidBecomeInactive(_ session: WCSession) { }
    public func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
    
}
