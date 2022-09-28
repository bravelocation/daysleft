//
//  DisplayValues.swift
//  DaysLeft
//
//  Created by John Pollard on 26/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Foundation

/// Display values used in the UI of the app
struct DisplayValues {
    /// Number of days left
    let daysLeft: Int
    
    /// Display title
    let title: String
    
    /// Description of days left
    let description: String
    
    /// Are we counting weekdays only?
    let weekdaysOnly: Bool
    
    /// Percenatge of the count done
    let percentageDone: Double
    
    /// Start date
    let start: Date
    
    /// End date
    let end: Date
    
    /// Current percentage left as a string
    let currentPercentageLeft: String
    
    /// Duration title used on the watch
    let watchDurationTitle: String
    
    /// Full title, used in shortchts etc.
    let fullTitle: String
    
    /// Days left description
    let daysLeftDescription: String
    
    /// Initialiser
    /// - Parameters:
    ///   - appSettings: App settings used in initialisation
    ///   - date: Current date - default is now
    init(appSettings: AppSettings, date: Date = Date()) {
        self.daysLeft = appSettings.daysLeft(date)
        self.title = appSettings.title
        self.weekdaysOnly = appSettings.weekdaysOnly
        self.description = appSettings.description(date)
        self.percentageDone = appSettings.percentageDone(date: date)
        self.start = appSettings.start
        self.end = appSettings.end
        self.currentPercentageLeft = appSettings.currentPercentageLeft(date: date)
        self.watchDurationTitle = appSettings.watchDurationTitle(date: date)
        self.fullTitle = appSettings.fullTitle(date: date)
        self.daysLeftDescription = appSettings.daysLeftDescription(date)
    }
}
