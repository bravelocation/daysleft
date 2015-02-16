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
    public var start: NSDate {
        get { return self.readObjectFromStore("start") as! NSDate }
        set { self.writeObjectToStore(newValue, key: "start") }
    }
    
    public var end: NSDate {
        get { return self.readObjectFromStore("end") as! NSDate }
        set { self.writeObjectToStore(newValue, key: "end") }
    }

    public var title: String {
        get { return self.readObjectFromStore("title") as! String }
        set { self.writeObjectToStore(newValue, key: "title") }
    }

    public var weekdaysOnly: Bool {
        get { return self.readObjectFromStore("weekdaysOnly") as! Bool }
        set { self.writeBoolToStore(newValue, key: "weekdaysOnly") }
    }
    
    public var hasInitialValue: Bool {
        get {
            // Return true if the start date is before the millenium i.e. the default value
            let dateStringFormatter = NSDateFormatter()
            dateStringFormatter.dateFormat = "yyyy-MM-dd"
            let millenium = dateStringFormatter.dateFromString("2000-01-01")
            return self.DaysDifference(millenium!, endDate: self.start) < 0
        }
    }
    
    public var DaysLength: Int {
        get {
            return self.DaysDifference(self.start, endDate: self.end) + 1; // Day count is inclusive, so add one to the total
        }
    }
    
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