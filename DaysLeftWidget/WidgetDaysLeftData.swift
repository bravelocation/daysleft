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
    
    var currentPercentageLeft: String = ""
    var currentTitle: String = ""
    var currentSubTitle: String = ""
    var percentageDone: Double = 0.0
    
    init(date: Date) {
        NSLog("Updating view data...")
        
        self.date = date
        
        // Reset the percentage done to 0.0
        self.percentageDone = 0.0
        
        // Set the published properties based on the model
        let model = DaysLeftModel()
        
        self.currentTitle = "\(model.daysLeftDescription(self.date)) until"
        self.currentSubTitle = model.title

        let percentageDone: Double = (Double(model.daysGone(self.date)) * 100.0) / Double(model.daysLength)
        self.percentageDone = percentageDone
        self.currentPercentageLeft = String(format: "%3.0f%% done", percentageDone)
    }
}
