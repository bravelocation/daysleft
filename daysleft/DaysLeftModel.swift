//
//  DaysLeftModel.swift
//  daysleft
//
//  Created by John Pollard on 11/02/2015.
//  Copyright (c) 2015 Brave Location Software. All rights reserved.
//

import Foundation
import WatchConnectivity

open class DaysLeftModel: BLUserSettings
{
    open static let iCloudSettingsNotification = "kBLiCloudSettingsNotification"
    open let currentFirstRun: Int = 1
    
    public init() {
        super.init()
        
        // Preload cache
        NSLog("Preloading settings cache...")
        self.settingsCache["start"] = self.appStandardUserDefaults!.value(forKey: "start")
        self.settingsCache["end"] = self.appStandardUserDefaults!.value(forKey: "end")
        self.settingsCache["title"] = self.appStandardUserDefaults!.value(forKey: "title")
        self.settingsCache["weekdaysOnly"] = self.appStandardUserDefaults!.value(forKey: "weekdaysOnly")
        
        self.initialRun()
        self.initialiseiCloudSettings()
    }

    /// Send updated settings to watch
    open func initialiseiCloudSettings() {
        NSLog("Initialising iCloud Settings")
        let store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default()
        NotificationCenter.default.addObserver(self, selector: #selector(DaysLeftModel.updateKVStoreItems(_:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: store)
        store.synchronize()
    }
    
    /// Send initial settings to watch
    open func pushAllSettingsToWatch() {
        self.initialiseWatchSession()
        
        if (WCSession.isSupported()) {
            let session = WCSession.default()
            session.transferUserInfo(self.allCurrentSettings())
            NSLog("Settings pushed to watch")
        }
    }
    
    /// Write settings to iCloud store
    open func writeSettingToiCloudStore(_ value: AnyObject, key: String) {
        let store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default()
        store.set(value, forKey: key)
        store.synchronize()
    }

    // Save value locally, and then write to iCloud store as appropriate
    open override func writeObjectToStore(_ value: AnyObject, key: String) {
        super.writeObjectToStore(value, key: key)
        self.writeSettingToiCloudStore(value, key: key)
    }
    
    /// Property to get and set the start date
    open var start: Date {
        get { return self.readObjectFromStore("start") as! Date }
        set { self.writeObjectToStore(self.StartOfDay(newValue) as AnyObject, key: "start") }
    }
    
    /// Property to get and set the end date
    open var end: Date {
        get { return self.readObjectFromStore("end") as! Date }
        set { self.writeObjectToStore(self.StartOfDay(newValue) as AnyObject, key: "end") }
    }

    /// Property to get and set the title
    open var title: String {
        get { return self.readObjectFromStore("title") as! String }
        set { self.writeObjectToStore(newValue as AnyObject, key: "title") }
    }

    /// Property to get and set the weekdays only flag
    open var weekdaysOnly: Bool {
        get { return self.readObjectFromStore("weekdaysOnly") as! Bool }
        set { self.writeObjectToStore(newValue as AnyObject, key: "weekdaysOnly") }
    }
    
    /// Property to get and set the firstRun value
    open var firstRun: Int {
        get { return self.readObjectFromStore("firstRun") as! Int }
        set { self.writeObjectToStore(newValue as AnyObject, key: "firstRun") }
    }
    
    /// Property to get the number of days between the start and the end
    open var DaysLength: Int {
        get {
            return self.DaysDifference(self.start, endDate: self.end) + 1 // Inclusive so add one
        }
    }
    
    /// Property to get and set the show badge flag
    open var showBadge: Bool {
        get { return self.readObjectFromStore("showBadge") as! Bool }
        set { self.writeObjectToStore(newValue as AnyObject, key: "showBadge") }
    }

    /// Finds the number of days to the end of the period from the current date
    ///
    /// param: currentDate The current date
    /// returns: The number of days to the end from the current date
    open func DaysLeft(_ currentDate: Date) -> Int {
        let startCurrentDate = self.StartOfDay(currentDate)
        
        // If the current date is before the start, return the length
        if (startCurrentDate.compare(self.start) == ComparisonResult.orderedAscending) {
            return self.DaysLength
        }
        
        // If the current date is after the end, return 0
        if (startCurrentDate.compare(self.end) == ComparisonResult.orderedDescending) {
            return 0
        }
        
        // Otherwise, return the actual difference
        return self.DaysLength - self.DaysGone(startCurrentDate)
    }
    
    /// Finds the number of days from the start of the period from the current date
    ///
    /// param: currentDate The current date
    /// returns: The number of days from the start to the current date
    open func DaysGone(_ currentDate: Date) -> Int  {
        let startCurrentDate = self.StartOfDay(currentDate)
        
        // If the current date is before the start, return 0
        if (startCurrentDate.compare(self.start) == ComparisonResult.orderedAscending) {
            return 0
        }
        
        // If the current date is after the end, return the length
        if (startCurrentDate.compare(self.end) == ComparisonResult.orderedDescending) {
            return self.DaysLength
        }
        
        // Otherwise, return the actual difference
        return self.DaysDifference(self.start, endDate: startCurrentDate) + 1 // Inclusive so add 1
    }
    
    open func initialRun() {
        if (self.firstRun < self.currentFirstRun)
        {
            // If it is first run, initialise the model data to Christmas
            let todayComponents = (Calendar.current as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: Date())
            let todayDate = Calendar.current.date(from: todayComponents)!
            
            var xmasComponents = DateComponents()
            xmasComponents.day = 25
            xmasComponents.month = 12
            xmasComponents.year = todayComponents.year
            
            var xmasDate: Date = Calendar.current.date(from: xmasComponents)!
            
            if (self.DaysDifference(todayDate, endDate: xmasDate) <= 0)
            {
                // If we're past Xmas in the year, set it to next year
                xmasComponents.year = xmasComponents.year! + 1
                xmasDate = Calendar.current.date(from: xmasComponents)!
            }
            
            self.start = todayDate
            self.end = xmasDate
            self.title = "Christmas"
            self.weekdaysOnly = false
            
            // Save the first run once working
            self.firstRun = self.currentFirstRun
        }
    }
    
    fileprivate func DaysDifference(_ startDate: Date, endDate: Date) -> Int {
        let globalCalendar: Calendar = Calendar.autoupdatingCurrent

        let startOfStartDate = self.StartOfDay(startDate)
        let startOfEndDate = self.StartOfDay(endDate)

        // If want all days, just calculate the days difference and return it
        if (!self.weekdaysOnly) {
            let components: DateComponents = (globalCalendar as NSCalendar).components(NSCalendar.Unit.day, from: startOfStartDate, to: startOfEndDate, options: NSCalendar.Options.wrapComponents)
            
            return components.day!
        }
        
        // If we are calculating weekdays only, first adjust the start or end date if on a weekend
        var startDayOfWeek: Int = (globalCalendar as NSCalendar).component(NSCalendar.Unit.weekday, from: startOfStartDate)
        var endDayOfWeek: Int = (globalCalendar as NSCalendar).component(NSCalendar.Unit.weekday, from: startOfEndDate)
            
        var adjustedStartDate = startOfStartDate
        var adjustedEndDate = startOfEndDate
            
        // If start is a weekend, adjust to Monday
        if (startDayOfWeek == 7) {
            // Saturday
            adjustedStartDate = self.AddDays(startOfStartDate, daysToAdd: 2)
        } else if (startDayOfWeek == 1) {
            // Sunday
            adjustedStartDate = self.AddDays(startOfStartDate, daysToAdd: 1)
        }
            
        // If end is a weekend, move it back to Friday
        if (endDayOfWeek == 7) {
            // Saturday
            adjustedEndDate = self.AddDays(startOfEndDate, daysToAdd: -1)
        } else if (endDayOfWeek == 1) {
            // Sunday
            adjustedEndDate = self.AddDays(startOfEndDate, daysToAdd: -2)
        }
            
        let adjustedComponents: DateComponents = (globalCalendar as NSCalendar).components(NSCalendar.Unit.day, from: adjustedStartDate, to: adjustedEndDate, options: NSCalendar.Options.wrapComponents)
            
        let adjustedTotalDays: Int = adjustedComponents.day!
        let fullWeeks: Int = adjustedTotalDays / 7
        
        // Now we need to take into account if the day of the start date is before or after the day of the end date
        startDayOfWeek = (globalCalendar as NSCalendar).component(NSCalendar.Unit.weekday, from: adjustedStartDate)
        endDayOfWeek = (globalCalendar as NSCalendar).component(NSCalendar.Unit.weekday, from: adjustedEndDate)
        
        var daysOfWeekDifference = endDayOfWeek - startDayOfWeek
        if (daysOfWeekDifference < 0) {
            daysOfWeekDifference += 5
        }

        // Finally return the number of weekdays
        return (fullWeeks * 5) + daysOfWeekDifference
    }
    
    open func StartOfDay(_ fullDate: Date) -> Date {

        let startOfDayComponents =  (Calendar.current as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: fullDate)
        
        return Calendar.current.date(from: startOfDayComponents)!
    }
    
    open func AddDays(_ originalDate: Date, daysToAdd: Int) -> Date {
        var dateComponents: DateComponents = DateComponents()
         dateComponents.day = daysToAdd
         return (Calendar.current as NSCalendar).date(byAdding: dateComponents, to: originalDate, options: [])!
    }
    
    fileprivate func allCurrentSettings() -> Dictionary<String, AnyObject> {
        var updatedSettings = Dictionary<String, AnyObject>()
        updatedSettings["start"] = self.start as AnyObject?
        updatedSettings["end"] = self.end as AnyObject?
        updatedSettings["title"] = self.title as AnyObject?
        updatedSettings["weekdaysOnly"] = self.weekdaysOnly as AnyObject?

        return updatedSettings;
    }
    
    open func FullDescription(_ currentDate: Date) -> String {        
        return String(format: "%d %@", self.DaysLeft(currentDate), self.Description(currentDate))
    }
    
    
    open func Description(_ currentDate: Date) -> String {
        let daysLeft: Int = self.DaysLeft(currentDate)
        
        var titleSuffix = "left"
        var titleDays = ""
        
        if (self.title.characters.count > 0) {
            titleSuffix = "until " + self.title
        }
        
        if (self.weekdaysOnly) {
            titleDays = (daysLeft == 1) ? "weekday" : "weekdays"
        } else {
            titleDays = (daysLeft == 1) ? "day" : "days"
        }
        
        return String(format: "%@ %@", titleDays, titleSuffix)
    }

    
    /// Used in the selector to handle incoming notifications of changes from the cloud
    ///
    /// param: notification The incoming notification
    @objc
    fileprivate func updateKVStoreItems(_ notification: Notification) {
        NSLog("Detected iCloud key-value storage change")
        
        // Get the list of keys that changed
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let reasonForChange: AnyObject? = userInfo.object(forKey: NSUbiquitousKeyValueStoreChangeReasonKey) as AnyObject?
        
        // Assuming we have a valid reason for the change
        if let downcastedReason = reasonForChange as? NSNumber {
            let reason: NSInteger = downcastedReason.intValue
            if ((reason == NSUbiquitousKeyValueStoreServerChange) || (reason == NSUbiquitousKeyValueStoreInitialSyncChange)) {
                // If something is changing externally, get the changes and update the corresponding keys locally.
                let changedKeys = userInfo.object(forKey: NSUbiquitousKeyValueStoreChangedKeysKey) as! [String]
                let store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default();
                
                // This loop assumes you are using the same key names in both the user defaults database and the iCloud key-value store
                for key:String in changedKeys {
                    let settingValue: AnyObject? = store.object(forKey: key) as AnyObject?
                    self.writeObjectToStore(settingValue!, key: key)
                    print("iCloud change for \(key): \(settingValue)")
                }
                
                store.synchronize()
                
                // Finally send a notification for the view controllers to refresh
                NotificationCenter.default.post(name: Notification.Name(rawValue: DaysLeftModel.iCloudSettingsNotification), object:nil, userInfo:nil)
                NSLog("Sent notification for iCloud change")
            }
        } else {
            NSLog("Unknown iCloud KV reason for change")
        }
    }
}
