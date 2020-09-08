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
        let entryDate = Calendar.current.startOfDay(for: Date()).addingTimeInterval(60*60*24)
        let entry = WidgetDaysLeftData(date: entryDate)
        entries.append(entry)

        let timeline = Timeline(entries: entries, policy: .atEnd)
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
        .configurationDisplayName("Days Left")
        .description("Count The Days Left")
    }
}

struct DaysLeftWidget_Previews: PreviewProvider {
    static var previews: some View {
        WidgetView(model: WidgetDaysLeftData(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
