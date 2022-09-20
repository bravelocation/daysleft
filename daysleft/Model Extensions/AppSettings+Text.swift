//
//  AppSettings+Text.swift
//  DaysLeft
//
//  Created by John Pollard on 20/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Foundation

extension AppSettings {
    func fullTitle(date: Date) -> String {
        return "\(self.daysLeftDescription(date)) to \(self.title)"
    }
    
    func percentageDone(date: Date) -> Double {
        return (Double(self.daysGone(date)) * 100.0) / Double(self.daysLength)
    }
    
    func currentPercentageLeft(date: Date) -> String {
        return String(format: "%3.0f%% done", self.percentageDone(date: date))
    }
}
