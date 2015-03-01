//
//  DaysLeftModel.swift
//  daysleft
//
//  Created by John Pollard on 11/02/2015.
//  Copyright (c) 2015 Brave Location Software. All rights reserved.
//

import Foundation

public class DaysLeftModel: BLUserSettings
{
    public let currentFirstRun: Int = 1;
    
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
        set { self.writeBoolToStore(newValue, key: "weekdaysOnly") }
    }
    
    /// Property to get and set the firstRun value
    public var firstRun: Int {
        get { return self.readObjectFromStore("firstRun") as! Int }
        set { self.writeIntegerToStore(newValue, key: "firstRun") }
    }
    
    /// Property to get the number of days between the start and the end
    public var DaysLength: Int {
        get {
            return self.DaysDifference(self.start, endDate: self.end) + 1 // Day count is inclusive, so add one to the total
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
        return self.DaysDifference(startCurrentDate, endDate: self.end)
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
        return self.DaysLength - self.DaysLeft(startCurrentDate);
    }
    
    public func initialRun() {
        if (self.firstRun < self.currentFirstRun)
        {
            // If it is first run, initialise the model data to Christmas
            var todayComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit, fromDate: NSDate())
            var todayDate = NSCalendar.currentCalendar().dateFromComponents(todayComponents)!
            
            var xmasComponents = NSDateComponents()
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

        var startOfStartDate = self.StartOfDay(startDate)
        var startOfEndDate = self.StartOfDay(endDate)

        let components: NSDateComponents = globalCalendar.components(NSCalendarUnit.CalendarUnitDay, fromDate: startOfStartDate, toDate: startOfEndDate, options: NSCalendarOptions.WrapComponents)
        
        var totalDays: Int = components.day
        if (self.weekdaysOnly) {
            
            var firstDayOfWeek: Int = globalCalendar.component(NSCalendarUnit.CalendarUnitWeekday, fromDate: startOfStartDate)
            var lastDayOfWeek: Int = globalCalendar.component(NSCalendarUnit.CalendarUnitWeekday, fromDate: startOfEndDate)
            
            var calculatedDays = ((totalDays * 5) - (firstDayOfWeek - lastDayOfWeek) * 2) / 7
            
            if (lastDayOfWeek == 7) {
                calculatedDays--
            }
            if (firstDayOfWeek == 1) {
                calculatedDays--
            }
            
            totalDays = calculatedDays
        }
        
        return totalDays
    }
    
    private func StartOfDay(fullDate: NSDate) -> NSDate {

        let preservedComponents = (NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit);
        let startOfDayComponents =  NSCalendar.currentCalendar().components(preservedComponents, fromDate: fullDate)
        
        return NSCalendar.currentCalendar().dateFromComponents(startOfDayComponents)!
    }
    
    private func AddDays(originalDate: NSDate, daysToAdd: Int) -> NSDate {
        let dateComponents: NSDateComponents = NSDateComponents()
         dateComponents.day = daysToAdd
         return NSCalendar.currentCalendar().dateByAddingComponents(dateComponents, toDate: originalDate, options: nil)!
    }
}