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

class WidgetDaysLeftData: ObservableObject, TimelineEntry {
    var date: Date
    var relevance: TimelineEntryRelevance? {
        return TimelineEntryRelevance(score: Float(self.percentageDone))
    }
    
    var currentPercentageLeft: String = ""
    var currentTitle: String = ""
    var percentageDone: Double = 0.0
    
    init(date: Date) {
        self.date = date
        
        // Reset the percentage done to 0.0
        self.percentageDone = 0.0
        
        // Set the published properties based on the model
        let appSettings = AppSettingsDataManager().appSettings
        
        self.currentTitle = "\(appSettings.daysLeftDescription(self.date)) to \(appSettings.title)"

        let percentageDone: Double = (Double(appSettings.daysGone(self.date)) * 100.0) / Double(appSettings.daysLength)
        self.percentageDone = percentageDone
        self.currentPercentageLeft = String(format: "%3.0f%% done", percentageDone)
    }
}
