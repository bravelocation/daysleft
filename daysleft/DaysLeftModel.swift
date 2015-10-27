//
//  DaysLeftModel.swift
//  daysleft
//
//  Created by John Pollard on 11/02/2015.
//  Copyright (c) 2015 Brave Location Software. All rights reserved.
//

import Foundation
import WatchConnectivity

public class DaysLeftModel: BLUserSettings
{
    public let currentFirstRun: Int = 1
    
    public init() {
        super.init()
        
        // Preload cache
        NSLog("Preloading settings cache...")
        self.settingsCache["start"] = self.appStandardUserDefaults!.valueForKey("start")
        self.settingsCache["end"] = self.appStandardUserDefaults!.valueForKey("end")
        self.settingsCache["title"] = self.appStandardUserDefaults!.valueForKey("title")
        self.settingsCache["weekdaysOnly"] = self.appStandardUserDefaults!.valueForKey("weekdaysOnly")
        
        self.initialRun()
        self.initialiseiCloudSettings()
        
        // Push settings to watch on background thread
        let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        dispatch_async(backgroundQueue, {
            self.pushAllSettingsToWatch()
        })
    }

    /// Send updated settings to watch
    public func initialiseiCloudSettings() {
        NSLog("Initialising iCloud Settings")
        let store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.defaultStore()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateKVStoreItems:", name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification, object: store)
        store.synchronize()
    }
    
    /// Send initial settings to watch
    public func pushAllSettingsToWatch() {
        self.initialiseWatchSession()
        
        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            
            var updatedSettings = Dictionary<String, AnyObject>()
            updatedSettings["start"] = self.appStandardUserDefaults!.valueForKey("start")
            updatedSettings["end"] = self.appStandardUserDefaults!.valueForKey("end")
            updatedSettings["title"] = self.appStandardUserDefaults!.valueForKey("title")
            updatedSettings["weekdaysOnly"] = self.appStandardUserDefaults!.valueForKey("weekdaysOnly")
            
            session.transferUserInfo(updatedSettings)
        }
        
        NSLog("Settings pushed to watch")
    }
    
    /// Write settings to iCloud store
    public func writeSettingToiCloudStore(value: AnyObject, key: String) {
        let store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.defaultStore()
        store.setObject(value, forKey: key)
        store.synchronize()
        
        self.pushAllSettingsToWatch()
    }

    // Save value locally, and then write to iClud store as appropriate
    public override func writeObjectToStore(value: AnyObject, key: String) {
        super.writeObjectToStore(value, key: key)
        self.writeSettingToiCloudStore(value, key: key)
    }
    
    /// Property to get and set the start date
    public var start: NSDate {
        get { return self.readObjectFromStore("start") as! NSDate }
        set { self.writeObjectToStore(self.StartOfDay(newValue), key: "start") }
    }
    
    /// Property to get and set the end date
    public var end: NSDate {
        get { return self.readObjectFromStore("end") as! NSDate }
        set { self.writeObjectToStore(self.StartOfDay(newValue), key: "end") }
    }

    /// Property to get and set the title
    public var title: String {
        get { return self.readObjectFromStore("title") as! String }
        set { self.writeObjectToStore(newValue, key: "title") }
    }

    /// Property to get and set the weekdays only flag
    public var weekdaysOnly: Bool {
        get { return self.readObjectFromStore("weekdaysOnly") as! Bool }
        set { self.writeObjectToStore(newValue, key: "weekdaysOnly") }
    }
    
    /// Property to get and set the firstRun value
    public var firstRun: Int {
        get { return self.readObjectFromStore("firstRun") as! Int }
        set { self.writeObjectToStore(newValue, key: "firstRun") }
    }
    
    /// Property to get the number of days between the start and the end
    public var DaysLength: Int {
        get {
            return self.DaysDifference(self.start, endDate: self.end) + 1 // Inclusive so add one
        }
    }

    /// Finds the number of days to the end of the period from the current date
    ///
    /// param: currentDate The current date
    /// returns: The number of days to the end from the current date
    public func DaysLeft(currentDate: NSDate) -> Int {
        let startCurrentDate = self.StartOfDay(currentDate)
        
        // If the current date is before the start, return the length
        if (startCurrentDate.compare(self.start) == NSComparisonResult.OrderedAscending) {
            return self.DaysLength
        }
        
        // If the current date is after the end, return 0
        if (startCurrentDate.compare(self.end) == NSComparisonResult.OrderedDescending) {
            return 0
        }
        
        // Otherwise, return the actual difference
        return self.DaysLength - self.DaysGone(startCurrentDate)
    }
    
    /// Finds the number of days from the start of the period from the current date
    ///
    /// param: currentDate The current date
    /// returns: The number of days from the start to the current date
    public func DaysGone(currentDate: NSDate) -> Int  {
        let startCurrentDate = self.StartOfDay(currentDate)
        
        // If the current date is before the start, return 0
        if (startCurrentDate.compare(self.start) == NSComparisonResult.OrderedAscending) {
            return 0
        }
        
        // If the current date is after the end, return the length
        if (startCurrentDate.compare(self.end) == NSComparisonResult.OrderedDescending) {
            return self.DaysLength
        }
        
        // Otherwise, return the actual difference
        return self.DaysDifference(self.start, endDate: startCurrentDate) + 1 // Inclusive so add 1
    }
    
    public func initialRun() {
        if (self.firstRun < self.currentFirstRun)
        {
            // If it is first run, initialise the model data to Christmas
            let todayComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: NSDate())
            let todayDate = NSCalendar.currentCalendar().dateFromComponents(todayComponents)!
            
            let xmasComponents = NSDateComponents()
            xmasComponents.day = 25
            xmasComponents.month = 12
            xmasComponents.year = todayComponents.year
            
            var xmasDate: NSDate = NSCalendar.currentCalendar().dateFromComponents(xmasComponents)!
            
            if (self.DaysDifference(todayDate, endDate: xmasDate) <= 0)
            {
                // If we're past Xmas in the year, set it to next year
                xmasComponents.year += 1
                xmasDate = NSCalendar.currentCalendar().dateFromComponents(xmasComponents)!
            }
            
            self.start = todayDate
            self.end = xmasDate
            self.title = "Christmas"
            self.weekdaysOnly = false
            
            // Save the first run once working
            self.firstRun = self.currentFirstRun
        }
    }
    
    private func DaysDifference(startDate: NSDate, endDate: NSDate) -> Int {
        let globalCalendar: NSCalendar = NSCalendar.autoupdatingCurrentCalendar()

        let startOfStartDate = self.StartOfDay(startDate)
        let startOfEndDate = self.StartOfDay(endDate)

        // If want all days, just calculate the days difference and return it
        if (!self.weekdaysOnly) {
            let components: NSDateComponents = globalCalendar.components(NSCalendarUnit.Day, fromDate: startOfStartDate, toDate: startOfEndDate, options: NSCalendarOptions.WrapComponents)
            
            return components.day
        }
        
        // If we are calculating weekdays only, first adjust the start or end date if on a weekend
        var startDayOfWeek: Int = globalCalendar.component(NSCalendarUnit.Weekday, fromDate: startOfStartDate)
        var endDayOfWeek: Int = globalCalendar.component(NSCalendarUnit.Weekday, fromDate: startOfEndDate)
            
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
            
        let adjustedComponents: NSDateComponents = globalCalendar.components(NSCalendarUnit.Day, fromDate: adjustedStartDate, toDate: adjustedEndDate, options: NSCalendarOptions.WrapComponents)
            
        let adjustedTotalDays: Int = adjustedComponents.day
        let fullWeeks: Int = adjustedTotalDays / 7
        
        // Now we need to take into account if the day of the start date is before or after the day of the end date
        startDayOfWeek = globalCalendar.component(NSCalendarUnit.Weekday, fromDate: adjustedStartDate)
        endDayOfWeek = globalCalendar.component(NSCalendarUnit.Weekday, fromDate: adjustedEndDate)
        
        var daysOfWeekDifference = endDayOfWeek - startDayOfWeek
        if (daysOfWeekDifference < 0) {
            daysOfWeekDifference += 5
        }

        // Finally return the number of weekdays
        return (fullWeeks * 5) + daysOfWeekDifference
    }
    
    public func StartOfDay(fullDate: NSDate) -> NSDate {

        let startOfDayComponents =  NSCalendar.currentCalendar().components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: fullDate)
        
        return NSCalendar.currentCalendar().dateFromComponents(startOfDayComponents)!
    }
    
    public func AddDays(originalDate: NSDate, daysToAdd: Int) -> NSDate {
        let dateComponents: NSDateComponents = NSDateComponents()
         dateComponents.day = daysToAdd
         return NSCalendar.currentCalendar().dateByAddingComponents(dateComponents, toDate: originalDate, options: [])!
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
                
                // This loop assumes you are using the same key names in both the user defaults database and the iCloud key-value store
                for key:String in changedKeys {
                    let settingValue: AnyObject? = store.objectForKey(key)
                    self.appStandardUserDefaults!.setObject(settingValue, forKey: key)
                }
            }
        } else {
            NSLog("Unknown iCloud KV reason for change")
        }
    }
}