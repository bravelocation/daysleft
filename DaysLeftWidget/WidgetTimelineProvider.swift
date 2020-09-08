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
    func placeholder(in context: Context) -> WidgetDaysLeftData {
        return WidgetDaysLeftData(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetDaysLeftData) -> Void) {
        let entry = WidgetDaysLeftData(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetDaysLeftData>) -> Void) {
        // Add entry just for now
        var entries: [WidgetDaysLeftData] = []
        let entry = WidgetDaysLeftData(date: Date())
        entries.append(entry)

        // Set expiry date to be start of tomorrow
        let entryDate = Calendar.current.startOfDay(for: Date()).addingTimeInterval(60*60*24)
        
        let timeline = Timeline(entries: entries, policy: .after(entryDate))
        completion(timeline)
    }
}
