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
    }
    
    /// Send initial settings to watch
    open func pushAllSettingsToWatch() {
        self.initialiseWatchSession()
        
        if (WCSession.isSupported()) {
            let session = WCSession.default
            session.transferUserInfo(self.allCurrentSettings())
            NSLog("Settings pushed to watch")
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
        set { self.writeObjectToStore(self.startOfDay(newValue) as AnyObject, key: "start") }
    }
    
    /// Property to get and set the end date
    open var end: Date {
        get { return self.readObjectFromStore("end") as! Date }
        set { self.writeObjectToStore(self.startOfDay(newValue) as AnyObject, key: "end") }
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
            return self.daysDifference(self.start, endDate: self.end) + 1 // Inclusive so add one
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
        let startCurrentDate = self.startOfDay(currentDate)
        
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
        let startCurrentDate = self.startOfDay(currentDate)
        
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
        return self.daysDifference(self.start, endDate: currentDate, currentDate: currentDate) + 1 // Inclusive so add 1
    }
    
    open func initialRun() {
        if (self.firstRun < self.currentFirstRun) {
            // If it is first run, initialise the model data to Christmas
            let todayComponents = (Calendar.current as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: Date())
            let todayDate = Calendar.current.date(from: todayComponents)!
            
            var xmasComponents = DateComponents()
            xmasComponents.day = 25
            xmasComponents.month = 12
            xmasComponents.year = todayComponents.year
            
            var xmasDate: Date = Calendar.current.date(from: xmasComponents)!
            
            if (self.daysDifference(todayDate, endDate: xmasDate) <= 0) {
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
    
    fileprivate func daysDifference(_ startDate: Date, endDate: Date, currentDate: Date? = nil) -> Int {
        let globalCalendar: Calendar = Calendar.autoupdatingCurrent

        let startOfStartDate = self.startOfDay(startDate)
        let startOfEndDate = self.startOfDay(endDate)

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
            adjustedStartDate = self.addDays(startOfStartDate, daysToAdd: 2)
        } else if (startDayOfWeek == 1) {
            // Sunday
            adjustedStartDate = self.addDays(startOfStartDate, daysToAdd: 1)
        }
        
        // If there is a current date, and the adjusted start date is after it, return -1) we haven't started yet)
        if let currentDate = currentDate {
            let startOfCurrentDate = self.startOfDay(currentDate)

            let startComparison = startOfCurrentDate.compare(adjustedStartDate)
            
            if (startComparison == ComparisonResult.orderedAscending) {
                return -1
            }
        }
            
        // If end is a weekend, move it back to Friday
        if (endDayOfWeek == 7) {
            // Saturday
            adjustedEndDate = self.addDays(startOfEndDate, daysToAdd: -1)
        } else if (endDayOfWeek == 1) {
            // Sunday
            adjustedEndDate = self.addDays(startOfEndDate, daysToAdd: -2)
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
    
    open func startOfDay(_ fullDate: Date) -> Date {

        let startOfDayComponents =  (Calendar.current as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: fullDate)
        
        return Calendar.current.date(from: startOfDayComponents)!
    }
    
    open func addDays(_ originalDate: Date, daysToAdd: Int) -> Date {
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
