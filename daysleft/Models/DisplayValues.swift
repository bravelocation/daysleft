//
//  DisplayValues.swift
//  DaysLeft
//
//  Created by John Pollard on 26/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Foundation

struct DisplayValues {
    let daysLeft: Int
    let title: String
    let description: String
    let weekdaysOnly: Bool
    let percentageDone: Double
    let start: Date
    let end: Date
    let currentPercentageLeft: String
    let watchDurationTitle: String
    let fullTitle: String
    let daysLeftDescription: String
    
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
