//
//  AppSettings.swift
//  DaysLeft
//
//  Created by John Pollard on 20/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Foundation

/// Current app settings
struct AppSettings {
    /// Start date
    let start: Date
    
    /// End date
    let end: Date
    
    /// Title
    let title: String
    
    /// Use weekdays only?
    let weekdaysOnly: Bool
    
    /// Property to get the number of days between the start and the end
    var daysLength: Int {
        get {
            return Date.daysDifference(self.start, endDate: self.end, weekdaysOnly: self.weekdaysOnly) + 1 // Inclusive so add one
        }
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
}
