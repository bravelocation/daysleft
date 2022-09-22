//
//  AppSettings+Text.swift
//  DaysLeft
//
//  Created by John Pollard on 20/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Foundation

extension AppSettings {
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
    
    func fullTitle(date: Date) -> String {
        return "\(self.daysLeftDescription(date)) to \(self.title)"
    }
    
    func percentageDone(date: Date) -> Double {
        return (Double(self.daysGone(date))) / Double(self.daysLength)
    }
    
    func currentPercentageLeft(date: Date) -> String {
        return String(format: "%.0f%% done", self.percentageDone(date: date) * 100.0)
    }
    
    func watchDurationTitle(date: Date) -> String {
        return "\(self.daysLeftDescription(date)) until"
    }
    
    func shortDateFormatted(date: Date) -> String {
        let shortDateFormatter = DateFormatter()
        shortDateFormatter.dateFormat = "EEE d MMM"
        
        return shortDateFormatter.string(from: date)
    }
}
