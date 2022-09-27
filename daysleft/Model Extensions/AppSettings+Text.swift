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
        
        var titleSuffix = NSLocalizedString("Time Left", comment: "")
        var titleDays = ""
        
        if (self.title.count > 0) {
            titleSuffix = "\(NSLocalizedString("Time until", comment: "")) \(self.title)"
        }
        
        if (self.weekdaysOnly) {
            let localised = NSLocalizedString("weekdays", comment: "")
            titleDays = String(format: localised, daysLeft)
        } else {
            let localised = NSLocalizedString("days", comment: "")
            titleDays = String(format: localised, daysLeft)
        }
        
        return String(format: "%@ %@", titleDays, titleSuffix)
    }
    
    func daysLeftDescription(_ currentDate: Date) -> String {
        let daysLeft: Int = self.daysLeft(currentDate)
        
        var titleDays = ""
        
        if (self.weekdaysOnly) {
            let localised = NSLocalizedString("weekdays", comment: "")
            titleDays = String(format: localised, daysLeft)
        } else {
            let localised = NSLocalizedString("days", comment: "")
            titleDays = String(format: localised, daysLeft)
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
        return "\(String(format: "%.0f%%", self.percentageDone(date: date) * 100.0)) \(NSLocalizedString("Time done", comment: ""))"
    }
    
    func watchDurationTitle(date: Date) -> String {
        return "\(self.daysLeftDescription(date)) \(NSLocalizedString("Time until", comment: ""))"
    }
}
