//
//  DaysLeftWidget.swift
//  DaysLeftWidget
//
//  Created by John Pollard on 08/09/2020.
//  Copyright © 2020 Brave Location Software. All rights reserved.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetDaysLeftData {
        return WidgetDaysLeftData(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetDaysLeftData) -> Void) {
        let entry = WidgetDaysLeftData(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetDaysLeftData>) -> Void) {
        var entries: [WidgetDaysLeftData] = []

        // Set expiry date to be start of tomorrow???
        let entry = WidgetDaysLeftData(date: Date())
        entries.append(entry)

        // Set expiry date to be start of tomorrow
        let entryDate = Calendar.current.startOfDay(for: Date()).addingTimeInterval(60*60*24)
        let timeline = Timeline(entries: entries, policy: .after(entryDate))
        completion(timeline)
    }
}

@main
struct DaysLeftWidget: Widget {
    let kind: String = "DaysLeftWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetView(model: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName("Days Left")
        .description("Count The Days Left")
    }
}

struct DaysLeftWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WidgetView(model: WidgetDaysLeftData(date: Date()))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            WidgetView(model: WidgetDaysLeftData(date: Date()))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
