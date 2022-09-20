//
//  DaysLeftModel.swift
//  daysleft
//
//  Created by John Pollard on 11/02/2015.
//  Copyright (c) 2015 Brave Location Software. All rights reserved.
//

import Foundation
import WatchConnectivity

open class DaysLeftModel: BLUserSettings {
    public let currentFirstRun: Int = 1
    
    public init() {
        super.init()
        
        // Preload cache
        print("Preloading settings cache...")
        self.settingsCache["start"] = self.appStandardUserDefaults!.value(forKey: "start")
        self.settingsCache["end"] = self.appStandardUserDefaults!.value(forKey: "end")
        self.settingsCache["title"] = self.appStandardUserDefaults!.value(forKey: "title")
        self.settingsCache["weekdaysOnly"] = self.appStandardUserDefaults!.value(forKey: "weekdaysOnly")
        
        self.initialRun()
        self.initialiseiCloudSettings()
    }

    /// Send updated settings to watch
    open func initialiseiCloudSettings() {
    }
    
    /// Send initial settings to watch
    open func pushAllSettingsToWatch() {
        self.initialiseWatchSession()
        
        if (WCSession.isSupported()) {
            let session = WCSession.default
            session.transferUserInfo(self.allCurrentSettings())
            print("Settings pushed to watch")
        }
    }
    
    /// Write settings to iCloud store
    open func writeSettingToiCloudStore(_ value: AnyObject, key: String) {
    }

    // Save value locally, and then write to iCloud store as appropriate
    open override func writeObjectToStore(_ value: AnyObject, key: String) {
        super.writeObjectToStore(value, key: key)
        self.writeSettingToiCloudStore(value, key: key)
    }
    
    /// Property to get and set the start date
    open var start: Date {
        get { return self.readObjectFromStore("start") as! Date }
        set { self.writeObjectToStore(newValue.startOfDay as AnyObject, key: "start") }
    }
    
    /// Property to get and set the end date
    open var end: Date {
        get { return self.readObjectFromStore("end") as! Date }
        set { self.writeObjectToStore(newValue.startOfDay as AnyObject, key: "end") }
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
    open var daysLength: Int {
        get {
            return Date.daysDifference(self.start, endDate: self.end, weekdaysOnly: self.weekdaysOnly) + 1 // Inclusive so add one
        }
    }
    
    /// Property to get and set the show badge flag
    open var showBadge: Bool {
        get { return self.readObjectFromStore("showBadge") as! Bool }
        set { self.writeObjectToStore(newValue as AnyObject, key: "showBadge") }
    }
    
    /// Property to get and set the is a supporter flag (called adsFree because of legacy usage)
    open var isASupporter: Bool {
        get { return self.readObjectFromStore("adsFree") as! Bool }
        set { self.writeObjectToStore(newValue as AnyObject, key: "adsFree") }
    }

    /// Property to get and set the number of times the app has been opened
    open var appOpenCount: Int {
        get { return self.readObjectFromStore("appOpenCount") as! Int }
        set { self.writeObjectToStore(newValue as AnyObject, key: "appOpenCount") }
    }

    /// Finds the number of days to the end of the period from the current date
    ///
    /// param: currentDate The current date
    /// returns: The number of days to the end from the current date
    open func daysLeft(_ currentDate: Date) -> Int {
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
    open func daysGone(_ currentDate: Date) -> Int {
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
    
    open func initialRun() {
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
    
    fileprivate func allCurrentSettings() -> Dictionary<String, Any> {
        var updatedSettings = Dictionary<String, Any>()
        updatedSettings["start"] = self.start
        updatedSettings["end"] = self.end
        updatedSettings["title"] = self.title
        updatedSettings["weekdaysOnly"] = self.weekdaysOnly

        return updatedSettings
    }
    
    open func fullDescription(_ currentDate: Date) -> String {        
        return String(format: "%d %@", self.daysLeft(currentDate), self.description(currentDate))
    }
    
    open func description(_ currentDate: Date) -> String {
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
    
    open func daysLeftDescription(_ currentDate: Date) -> String {
        let daysLeft: Int = self.daysLeft(currentDate)
        
        var titleDays = ""
        
        if (self.weekdaysOnly) {
            titleDays = (daysLeft == 1) ? "weekday" : "weekdays"
        } else {
            titleDays = (daysLeft == 1) ? "day" : "days"
        }
        
        return String(format: "%d %@", daysLeft, titleDays)
    }
}
