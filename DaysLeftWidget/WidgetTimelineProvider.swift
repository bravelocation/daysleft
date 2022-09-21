//
//  WidgetTimelineProvider.swift
//  DaysLeftWidgetExtension
//
//  Created by John Pollard on 08/09/2020.
//  Copyright © 2020 Brave Location Software. All rights reserved.
//

import Foundation
import WidgetKit
import SwiftUI

struct WidgetTimelineProvider: TimelineProvider {
    let appSettings = AppSettingsDataManager().appSettings
    
    func placeholder(in context: Context) -> WidgetDaysLeftData {
        return WidgetDaysLeftData(date: Date(), appSettings: self.appSettings)
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetDaysLeftData) -> Void) {
        let entry = WidgetDaysLeftData(date: Date(), appSettings: self.appSettings)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetDaysLeftData>) -> Void) {
        // Add entry just for now
        var entries: [WidgetDaysLeftData] = []
        let entry = WidgetDaysLeftData(date: Date(), appSettings: self.appSettings)
        entries.append(entry)

        // Update the widget every hour
        var entryDate = Date().addingTimeInterval(60*60)
        
        // If the expiry time is tomorrow, set it to be start of tomorrow
        if Calendar.current.component(.hour, from: entryDate) == 0 {
            entryDate = Calendar.current.startOfDay(for: Date()).addingTimeInterval(60*60*24)
        }

        let timeline = Timeline(entries: entries, policy: .after(entryDate))
        completion(timeline)
    }
}
