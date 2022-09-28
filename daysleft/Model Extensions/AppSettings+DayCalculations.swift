//
//  AppSettings+DayCalculations.swift
//  DaysLeft
//
//  Created by John Pollard on 20/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Foundation

extension AppSettings {
    
    /// Property to get the number of days between the start and the end
    var daysLength: Int {
        get {
            return Date.daysDifference(self.start, endDate: self.end, weekdaysOnly: self.weekdaysOnly) + 1 // Inclusive so add one
        }
    }
    
    /// Finds the number of days to the end of the period from the current date
    ///
    /// - Parameter currentDate: The current date
    /// - Returns: The number of days to the end from the current date
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
    /// - Parameter currentDate: The current date
    /// - Returns: The number of days from the start to the current date
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
}
