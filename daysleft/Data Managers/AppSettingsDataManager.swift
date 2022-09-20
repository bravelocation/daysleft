//
//  AppSettingsDataManager.swift
//  DaysLeft
//
//  Created by John Pollard on 20/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Foundation

class AppSettingsDataManager {
    
    // MARK: - Properties

    /// Notification name for when the data has been updated
    public static let UpdateSettingsNotification = "UpdateSettingsNotification"
    
    /// User defaults
    var appStandardUserDefaults: UserDefaults?
    
    /// Settings cache used to store settings locally for faster access
    var settingsCache = Dictionary<String, Any>()
    
    /// Has the watch session been initialised
    var watchSessionInitialised: Bool = false
    
    /// Is this the current first run (integer not boolean for legacy reasons)
    let currentFirstRun: Int = 1
    
    // MARK: - Initialisation functions
    
    /// Default initialiser for the class
    ///
    /// param: defaultPreferencesName The name of the plist file containing the default preferences
    public init(defaultPreferencesName: String = "DefaultPreferences", suiteName: String = "group.bravelocation.daysleft") {

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
        
        self.initialRun()
        self.initialiseiCloudSettings()
    }
    
    /// Initial setting up of data on first run of the app
    func initialRun() {
        if (self.firstRun < self.currentFirstRun) {
            // If it is first run, initialise the model data to Christmas
            self.start = Date().startOfDay
            self.end = Date.nextXmas()
            self.title = "Christmas"
            self.weekdaysOnly = false
            
            // Save the first run once working
            self.firstRun = self.currentFirstRun
        }
    }
    
    // MARK: - iCloud functions
    
    /// Send updated settings to watch
    private func initialiseiCloudSettings() {
        print("Initialising iCloud Settings")
        let store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AppSettingsDataManager.updateKVStoreItems(_:)),
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
                NotificationCenter.default.post(name: Notification.Name(rawValue: AppSettingsDataManager.UpdateSettingsNotification), object: nil, userInfo: nil)
                print("Sent notification for iCloud change")
            }
        } else {
            print("Unknown iCloud KV reason for change")
        }
    }
    
    // MARK: - Settings values
    
    /// Main app settings
    var appSettings: AppSettings {
        get {
            return AppSettings(start: self.start,
                               end: self.end,
                               title: self.title,
                               weekdaysOnly: self.weekdaysOnly)
        }
        set {
            self.start = newValue.start
            self.end = newValue.end
            self.title = newValue.title
            self.weekdaysOnly = newValue.weekdaysOnly
        }
    }
    
    /// App control settings
    var appControlSettings: AppControlSettings {
        get {
            return AppControlSettings(firstRun: self.firstRun,
                                      showBadge: self.showBadge,
                                      isASupporter: self.isASupporter,
                                      appOpenCount: self.appOpenCount)
        }
        set {
            self.firstRun = newValue.firstRun
            self.showBadge = newValue.showBadge
            self.isASupporter = newValue.isASupporter
            self.appOpenCount = newValue.appOpenCount
        }
    }
    
    /// Property to get and set the start date
    private var start: Date {
        get { return self.readObjectFromStore("start") as! Date }
        set { self.writeObjectToStore(newValue.startOfDay as AnyObject, key: "start") }
    }
    
    /// Property to get and set the end date
    private var end: Date {
        get { return self.readObjectFromStore("end") as! Date }
        set { self.writeObjectToStore(newValue.startOfDay as AnyObject, key: "end") }
    }

    /// Property to get and set the title
    private var title: String {
        get { return self.readObjectFromStore("title") as! String }
        set { self.writeObjectToStore(newValue as AnyObject, key: "title") }
    }

    /// Property to get and set the weekdays only flag
    private var weekdaysOnly: Bool {
        get { return self.readObjectFromStore("weekdaysOnly") as! Bool }
        set { self.writeObjectToStore(newValue as AnyObject, key: "weekdaysOnly") }
    }
    
    /// Property to get and set the firstRun value
    private var firstRun: Int {
        get { return self.readObjectFromStore("firstRun") as! Int }
        set { self.writeObjectToStore(newValue as AnyObject, key: "firstRun") }
    }
    
    /// Property to get and set the show badge flag
    private var showBadge: Bool {
        get { return self.readObjectFromStore("showBadge") as! Bool }
        set { self.writeObjectToStore(newValue as AnyObject, key: "showBadge") }
    }
    
    /// Property to get and set the is a supporter flag (called adsFree because of legacy usage)
    private var isASupporter: Bool {
        get { return self.readObjectFromStore("adsFree") as! Bool }
        set { self.writeObjectToStore(newValue as AnyObject, key: "adsFree") }
    }

    /// Property to get and set the number of times the app has been opened
    private var appOpenCount: Int {
        get { return self.readObjectFromStore("appOpenCount") as! Int }
        set { self.writeObjectToStore(newValue as AnyObject, key: "appOpenCount") }
    }
    
    // MARK: - Read and write to settings store
 
    /// Used to read an object setting from the user setting store
    ///
    /// param: key The key for the setting
    /// returns: An AnyObject? value retrieved from the settings store
    private func readObjectFromStore(_ key: String) -> Any? {
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
    private func writeObjectToStore(_ value: AnyObject, key: String) {
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
}
