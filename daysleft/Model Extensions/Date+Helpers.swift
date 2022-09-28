//
//  Date+Extensions.swift
//  DaysLeft
//
//  Created by John Pollard on 19/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Foundation

extension Date {
    /// Returns the start of the day based on the current date
    var startOfDay: Date {
        let startOfDayComponents = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(from: startOfDayComponents)!
    }
    
    /// Adds a number of days to the current date
    /// - Parameter daysToAdd: Number of days to add
    /// - Returns: Date with days added
    func addDays(_ daysToAdd: Int) -> Date {
        var dateComponents: DateComponents = DateComponents()
        dateComponents.day = daysToAdd
        return Calendar.current.date(byAdding: dateComponents, to: self)!
    }
    
    /// Number of days between two dates
    /// - Parameters:
    ///   - startDate: Start date
    ///   - endDate: End date
    ///   - currentDate: Current date used in calulations
    ///   - weekdaysOnly: Should we use weekdays only in the calculations
    /// - Returns: Number of days bwteen the dates
    static func daysDifference(_ startDate: Date, endDate: Date, currentDate: Date? = nil, weekdaysOnly: Bool) -> Int {
        let startOfStartDate = startDate.startOfDay
        let startOfEndDate = endDate.startOfDay

        // If want all days, just calculate the days difference and return it
        if (!weekdaysOnly) {
            let components: DateComponents = Calendar.current.dateComponents([.day], from: startOfStartDate, to: startOfEndDate)
            
            return components.day!
        }
        
        // If we are calculating weekdays only, first adjust the start or end date if on a weekend
        var startDayOfWeek: Int = Calendar.current.component(.weekday, from: startOfStartDate)
        var endDayOfWeek: Int = Calendar.current.component(.weekday, from: startOfEndDate)
            
        var adjustedStartDate = startOfStartDate
        var adjustedEndDate = startOfEndDate
            
        // If start is a weekend, adjust to Monday
        if (startDayOfWeek == 7) {
            // Saturday
            adjustedStartDate = startOfStartDate.addDays(2)
        } else if (startDayOfWeek == 1) {
            // Sunday
            adjustedStartDate = startOfStartDate.addDays(1)
        }
        
        // If there is a current date, and the adjusted start date is after it, return -1) we haven't started yet)
        if let currentDate = currentDate {
            let startOfCurrentDate = currentDate.startOfDay

            let startComparison = startOfCurrentDate.compare(adjustedStartDate)
            
            if (startComparison == ComparisonResult.orderedAscending) {
                return -1
            }
        }
            
        // If end is a weekend, move it back to Friday
        if (endDayOfWeek == 7) {
            // Saturday
            adjustedEndDate = startOfEndDate.addDays(-1)
        } else if (endDayOfWeek == 1) {
            // Sunday
            adjustedEndDate = startOfEndDate.addDays(-2)
        }
            
        let adjustedComponents: DateComponents = Calendar.current.dateComponents([.day], from: adjustedStartDate, to: adjustedEndDate)
            
        let adjustedTotalDays: Int = adjustedComponents.day!
        let fullWeeks: Int = adjustedTotalDays / 7
        
        // Now we need to take into account if the day of the start date is before or after the day of the end date
        startDayOfWeek = Calendar.current.component(.weekday, from: adjustedStartDate)
        endDayOfWeek = Calendar.current.component(.weekday, from: adjustedEndDate)
        
        var daysOfWeekDifference = endDayOfWeek - startDayOfWeek
        if (daysOfWeekDifference < 0) {
            daysOfWeekDifference += 5
        }

        // Finally return the number of weekdays
        return (fullWeeks * 5) + daysOfWeekDifference
    }
    
    /// Returns the next Xmas
    /// - Returns: Date of next Xmas
    static func nextXmas() -> Date {
        // If it is first run, initialise the model data to Christmas
        let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        let todayDate = Calendar.current.date(from: todayComponents)!
        
        var xmasComponents = DateComponents()
        xmasComponents.day = 25
        xmasComponents.month = 12
        xmasComponents.year = todayComponents.year
        
        var xmasDate: Date = Calendar.current.date(from: xmasComponents)!
        
        if (Date.daysDifference(todayDate, endDate: xmasDate, weekdaysOnly: false) <= 0) {
            // If we're past Xmas in the year, set it to next year
            xmasComponents.year = xmasComponents.year! + 1
            xmasDate = Calendar.current.date(from: xmasComponents)!
        }
        
        return xmasDate
    }
}
