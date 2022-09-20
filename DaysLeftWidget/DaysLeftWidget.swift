//
//  DaysLeftWidget.swift
//  DaysLeftWidget
//
//  Created by John Pollard on 08/09/2020.
//  Copyright © 2020 Brave Location Software. All rights reserved.
//

import WidgetKit
import SwiftUI

@main
struct DaysLeftWidget: Widget {
    let kind: String = "DaysLeftWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: WidgetTimelineProvider()) { entry in
            WidgetView(model: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName("Days Left")
        .description("Count The Days Left")
    }
}

struct DaysLeftWidget_Previews: PreviewProvider {
    static var appSettings = AppSettingsDataManager(dataProvider: InMemoryDataProvider()).appSettings
    
    static var previews: some View {
        Group {
            WidgetView(model: WidgetDaysLeftData(date: Date(), appSettings: appSettings))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            WidgetView(model: WidgetDaysLeftData(date: Date(), appSettings: appSettings))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
