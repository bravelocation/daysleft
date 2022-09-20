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
    let appSettings: AppSettings
    
    var relevance: TimelineEntryRelevance? {
        return TimelineEntryRelevance(score: Float(self.appSettings.percentageDone(date: self.date)))
    }
    
    init(date: Date, appSettings: AppSettings) {
        self.date = date
        self.appSettings = appSettings
    }
}
