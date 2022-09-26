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
    let date: Date
    let displayValues: DisplayValues
    
    var relevance: TimelineEntryRelevance? {
        return TimelineEntryRelevance(score: Float(self.displayValues.percentageDone))
    }
    
    init(date: Date, appSettings: AppSettings) {
        self.date = date
        self.displayValues = DisplayValues(appSettings: appSettings, date: date)
    }
}
