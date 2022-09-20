//
//  AppSettingsDataManager.swift
//  DaysLeft
//
//  Created by John Pollard on 20/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Foundation
import WatchConnectivity

class AppSettingsDataManager: NSObject, WCSessionDelegate {
    
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
        
        // Need to inherit from NSObject, so call super.init()
        super.init()
        
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
    
    /// Initialise watch session if required
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
    
    // MARK: - Watch synchronisation functions
    
    /// Send initial settings to watch
    func pushAllSettingsToWatch() {
        self.initialiseWatchSession()
        
        if (WCSession.isSupported()) {
            let session = WCSession.default
            
            var updatedSettings = Dictionary<String, Any>()
            updatedSettings["start"] = self.start
            updatedSettings["end"] = self.end
            updatedSettings["title"] = self.title
            updatedSettings["weekdaysOnly"] = self.weekdaysOnly
            
            session.transferUserInfo(updatedSettings)
            print("Settings pushed to watch")
        }
    }
    
    // MARK: - iCloud placeholder functions
    
    /// Do nothing by default, can be overriden in child classes
    func initialiseiCloudSettings() {
    }
    
    /// Write settings to iCloud store
    func writeSettingToiCloudStore(_ value: AnyObject, key: String) {
    }
    
    // MARK: - Settings values
    
    /// Property to get and set the start date
    var start: Date {
        get { return self.readObjectFromStore("start") as! Date }
        set { self.writeObjectToStore(newValue.startOfDay as AnyObject, key: "start") }
    }
    
    /// Property to get and set the end date
    var end: Date {
        get { return self.readObjectFromStore("end") as! Date }
        set { self.writeObjectToStore(newValue.startOfDay as AnyObject, key: "end") }
    }

    /// Property to get and set the title
    var title: String {
        get { return self.readObjectFromStore("title") as! String }
        set { self.writeObjectToStore(newValue as AnyObject, key: "title") }
    }

    /// Property to get and set the weekdays only flag
    var weekdaysOnly: Bool {
        get { return self.readObjectFromStore("weekdaysOnly") as! Bool }
        set { self.writeObjectToStore(newValue as AnyObject, key: "weekdaysOnly") }
    }
    
    /// Property to get and set the firstRun value
    var firstRun: Int {
        get { return self.readObjectFromStore("firstRun") as! Int }
        set { self.writeObjectToStore(newValue as AnyObject, key: "firstRun") }
    }
    
    /// Property to get the number of days between the start and the end
    var daysLength: Int {
        get {
            return Date.daysDifference(self.start, endDate: self.end, weekdaysOnly: self.weekdaysOnly) + 1 // Inclusive so add one
        }
    }
    
    /// Property to get and set the show badge flag
    var showBadge: Bool {
        get { return self.readObjectFromStore("showBadge") as! Bool }
        set { self.writeObjectToStore(newValue as AnyObject, key: "showBadge") }
    }
    
    /// Property to get and set the is a supporter flag (called adsFree because of legacy usage)
    var isASupporter: Bool {
        get { return self.readObjectFromStore("adsFree") as! Bool }
        set { self.writeObjectToStore(newValue as AnyObject, key: "adsFree") }
    }

    /// Property to get and set the number of times the app has been opened
    var appOpenCount: Int {
        get { return self.readObjectFromStore("appOpenCount") as! Int }
        set { self.writeObjectToStore(newValue as AnyObject, key: "appOpenCount") }
    }

    /// Finds the number of days to the end of the period from the current date
    ///
    /// param: currentDate The current date
    /// returns: The number of days to the end from the current date
    func daysLeft(_ currentDate: Date) -> Int {
        let startCurrentDate = currentDate.startOfDay
        
        // If the current date is before the start, return the length
        let startComparison = startCurrentDate.compare(self.start)
        
        if (startComparison == ComparisonResult.orderedAscending) {
            return self.daysLength
        }
        
        // If the current date is after the end, return 0
        if (startCurrentDate.compare(self.end) == ComparisonResult.orderedDescending) {
            return 0
        }
        
        // Otherwise, return the actual difference
        return self.daysLength - self.daysGone(startCurrentDate)
    }
    
    /// Finds the number of days from the start of the period from the current date
    ///
    /// param: currentDate The current date
    /// returns: The number of days from the start to the current date
    func daysGone(_ currentDate: Date) -> Int {
        let startCurrentDate = currentDate.startOfDay
        
        let startComparison = startCurrentDate.compare(self.start)
        
        // If the current date is before the start (not weekdays only), return 0
        if (startComparison == ComparisonResult.orderedAscending && self.weekdaysOnly == false) {
            return 0
        }
        
        // If the current date is after the end, return the length
        if (startCurrentDate.compare(self.end) == ComparisonResult.orderedDescending) {
            return self.daysLength
        }
        
        // Otherwise, return the actual difference
        return Date.daysDifference(self.start, endDate: currentDate, currentDate: currentDate, weekdaysOnly: self.weekdaysOnly) + 1 // Inclusive so add 1
    }
    
    func fullDescription(_ currentDate: Date) -> String {
        return String(format: "%d %@", self.daysLeft(currentDate), self.description(currentDate))
    }
    
    func description(_ currentDate: Date) -> String {
        let daysLeft: Int = self.daysLeft(currentDate)
        
        var titleSuffix = "left"
        var titleDays = ""
        
        if (self.title.count > 0) {
            titleSuffix = "until " + self.title
        }
        
        if (self.weekdaysOnly) {
            titleDays = (daysLeft == 1) ? "weekday" : "weekdays"
        } else {
            titleDays = (daysLeft == 1) ? "day" : "days"
        }
        
        return String(format: "%@ %@", titleDays, titleSuffix)
    }
    
    func daysLeftDescription(_ currentDate: Date) -> String {
        let daysLeft: Int = self.daysLeft(currentDate)
        
        var titleDays = ""
        
        if (self.weekdaysOnly) {
            titleDays = (daysLeft == 1) ? "weekday" : "weekdays"
        } else {
            titleDays = (daysLeft == 1) ? "day" : "days"
        }
        
        return String(format: "%d %@", daysLeft, titleDays)
    }
    
    // MARK: - Read and write to settings store
 
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
    
    // MARK: - WCSessionDelegate functions
    
    /// WCSessionDelegate implementation - update local settings when transfered from phone
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        print("New user info transfer data received on watch")
        
        for (key, value) in userInfo {
            self.writeObjectToStore(value as AnyObject, key: key)
        }
        
        // Finally send a notification for the view controllers to refresh
        NotificationCenter.default.post(name: Notification.Name(rawValue: AppSettingsDataManager.UpdateSettingsNotification), object: nil, userInfo: nil)
        print("Sent UpdateSettingsNotification")
    }
    
    @nonobjc func session(_ session: WCSession, didReceiveUpdate receivedApplicationContext: [String: AnyObject]) {
        print("New context transfer data received on watch")
        
        for (key, value) in receivedApplicationContext {
            self.writeObjectToStore(value, key: key)
        }
        
        // Finally send a notification for the view controllers to refresh
        NotificationCenter.default.post(name: Notification.Name(rawValue: AppSettingsDataManager.UpdateSettingsNotification), object: nil, userInfo: nil)
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
