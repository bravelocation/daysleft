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
        set { self.writeObjectToStore(newValue, key: "start") }
    }
    
    /// Property to get and set the end date
    public var end: NSDate {
        get { return self.readObjectFromStore("end") as! NSDate }
        set { self.writeObjectToStore(newValue, key: "end") }
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
            return self.DaysDifference(self.start, endDate: self.end) + 1; // Day count is inclusive, so add one to the total
        }
    }

    /// Finds the number of days to the end of the period from the current date
    ///
    /// param: currentDate The current date
    /// returns: The number of days to the end from the current date
    public func DaysLeft(currentDate: NSDate) -> Int {
        // If the current date is before the start, return the length
        if (currentDate.compare(self.start) == NSComparisonResult.OrderedAscending) {
            return self.DaysLength
        }
        
        // If the current date is after the end, return 0
        if (currentDate.compare(self.end) == NSComparisonResult.OrderedDescending) {
            return 0
        }
        
        // Otherwise, return the actual difference
        return self.DaysDifference(currentDate, endDate: self.end);
    }
    
    /// Finds the number of days from the start of the period from the current date
    ///
    /// param: currentDate The current date
    /// returns: The number of days from the start to the current date
    public func DaysGone(currentDate: NSDate) -> Int  {
        // If the current date is before the start, return 0
        if (currentDate.compare(self.start) == NSComparisonResult.OrderedAscending) {
            return 0
        }
        
        // If the current date is after the end, return the length
        if (currentDate.compare(self.end) == NSComparisonResult.OrderedDescending) {
            return self.DaysLength
        }
        
        // Otherwise, return the actual difference
        return self.DaysLength - self.DaysLeft(currentDate);
    }
    
    private func DaysDifference(startDate: NSDate, endDate: NSDate) -> Int {
        let globalCalendar: NSCalendar = NSCalendar.autoupdatingCurrentCalendar()
        
        let components: NSDateComponents = globalCalendar.components(NSCalendarUnit.CalendarUnitDay, fromDate: startDate, toDate: endDate, options: NSCalendarOptions.WrapComponents)
        
        var totalDays: Int = components.day
        if (self.weekdaysOnly) {
            
            var firstDayOfWeek: Int = globalCalendar.component(NSCalendarUnit.CalendarUnitWeekday, fromDate: startDate)
            var lastDayOfWeek: Int = globalCalendar.component(NSCalendarUnit.CalendarUnitWeekday, fromDate: endDate)

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
}