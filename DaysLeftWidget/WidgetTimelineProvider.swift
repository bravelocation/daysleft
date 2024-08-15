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
import AppIntents

/// Widget timeline provider
struct WidgetTimelineProvider: TimelineProvider {
    /// Placeholder data
    /// - Parameter context: Current context
    /// - Returns: Widget data to be used in placeholder
    func placeholder(in context: Context) -> WidgetDaysLeftData {
        let dataManager = AppSettingsDataManager()
        
        return WidgetDaysLeftData(date: Date(), appSettings: dataManager.appSettings)
    }
    
    /// Handler provider for snapshot
    /// - Parameters:
    ///   - context: Current context
    ///   - completion: Completion handler
    func getSnapshot(in context: Context, completion: @escaping (WidgetDaysLeftData) -> Void) {
        let dataManager = AppSettingsDataManager()

        let entry = WidgetDaysLeftData(date: Date(), appSettings: dataManager.appSettings)
        completion(entry)
    }
    
    /// Timeline provider
    /// - Parameters:
    ///   - context: Current context
    ///   - completion: Completion handler
    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetDaysLeftData>) -> Void) {
        let dataManager = AppSettingsDataManager()
        let appSettings = dataManager.appSettings

        // Add entry just for now
        var entries: [WidgetDaysLeftData] = []
        let entry = WidgetDaysLeftData(date: Date(), appSettings: appSettings)
        entries.append(entry)

        // Update the widget every hour
        var entryDate = Date().addingTimeInterval(60*60)
        
        // If the expiry time is tomorrow, set it to be start of tomorrow
        if Calendar.current.isDateInTomorrow(entryDate) {
            entryDate = Calendar.current.startOfDay(for: entryDate)
        }

        let timeline = Timeline(entries: entries, policy: .after(entryDate))
        completion(timeline)
    }
}

@available(iOS 17, watchOS 10.0, *)
struct AppIntentWidgetTimelineProvider: AppIntentTimelineProvider {
    typealias Entry = WidgetDaysLeftData
    typealias Intent = DaysLeftWidgetConfigurationIntent
    
    let baseTimeline: WidgetTimelineProvider = WidgetTimelineProvider()
    
    func placeholder(in context: Context) -> WidgetDaysLeftData {
        return baseTimeline.placeholder(in: context)
    }
    
    func snapshot(for configuration: DaysLeftWidgetConfigurationIntent, in context: Context) async -> WidgetDaysLeftData {
        let data = await withCheckedContinuation { continuation in
            baseTimeline.getSnapshot(in: context) { data in
                continuation.resume(returning: data)
            }
        }
        
        return data
    }
    
    func timeline(for configuration: DaysLeftWidgetConfigurationIntent, in context: Context) async -> Timeline<WidgetDaysLeftData> {
        let dataManager = AppSettingsDataManager()
        let appSettings = dataManager.appSettings

        // Add entry just for now
        var entries: [WidgetDaysLeftData] = []
        let entry = WidgetDaysLeftData(date: Date(), appSettings: appSettings)
        entries.append(entry)

        // Update the widget every hour
        var entryDate = Date().addingTimeInterval(60*60)
        
        // If the expiry time is tomorrow, set it to be start of tomorrow
        if Calendar.current.isDateInTomorrow(entryDate) {
            entryDate = Calendar.current.startOfDay(for: entryDate)
        }

        let timeline = Timeline(entries: entries, policy: .after(entryDate))
        
        return timeline
    }
    
    func recommendations() -> [AppIntentRecommendation<DaysLeftWidgetConfigurationIntent>] {
        var recs = [AppIntentRecommendation<DaysLeftWidgetConfigurationIntent>]()

        let configIntent = DaysLeftWidgetConfigurationIntent()
        let recommendation = AppIntentRecommendation(intent: configIntent, description: "None")
        recs.append(recommendation)

        return recs
    }
}
