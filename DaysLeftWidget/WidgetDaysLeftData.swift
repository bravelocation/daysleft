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

/// Timelien entry used in widgets
final class WidgetDaysLeftData: TimelineEntry, Sendable {
    /// Current date
    let date: Date
    
    /// Display values for widget
    let displayValues: DisplayValues
    
    /// Relevance - more relevant closer to end date
    var relevance: TimelineEntryRelevance? {
        return TimelineEntryRelevance(score: Float(self.displayValues.percentageDone))
    }
    
    /// Initialiser
    /// - Parameters:
    ///   - date: Current date
    ///   - appSettings: App settings
    init(date: Date, appSettings: AppSettings) {
        self.date = date
        self.displayValues = DisplayValues(appSettings: appSettings, date: date)
    }
}
