//
//  WidgetDaysLeftData.swift
//  DaysLeftWidgetExtension
//
//  Created by John Pollard on 08/09/2020.
//  Copyright © 2020 Brave Location Software. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import WidgetKit

class WidgetDaysLeftData: TimelineEntry {
    var date: Date
    var relevance: TimelineEntryRelevance? {
        return TimelineEntryRelevance(score: Float(self.percentageDone))
    }
    
    let currentPercentageLeft: String
    let currentTitle: String
    let percentageDone: Double
    
    init(date: Date, appSettings: AppSettings) {
        self.date = date
        
        self.currentTitle = "\(appSettings.daysLeftDescription(self.date)) to \(appSettings.title)"
        self.percentageDone = (Double(appSettings.daysGone(self.date)) * 100.0) / Double(appSettings.daysLength)
        self.currentPercentageLeft = String(format: "%3.0f%% done", percentageDone)
    }
}
