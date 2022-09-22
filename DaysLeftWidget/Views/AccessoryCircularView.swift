//
//  AccessoryCircularView.swift
//  DaysLeftWidgetExtension
//
//  Created by John Pollard on 22/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 16.0, *)
struct AccessoryCircularView: View {
    var model: WidgetDaysLeftData
        @Environment(\.showsWidgetLabel) var showsWidgetLabel
    
    var body: some View {
        if showsWidgetLabel {
            Gauge(value: model.appSettings.percentageDone(date: model.date)) {
                Text(self.model.appSettings.weekdaysOnly ? "WKDY" : "DAYS")
            } currentValueLabel: {
                Text("\(self.model.appSettings.daysLeft(model.date))")
            }
                .gaugeStyle(.accessoryCircular)
                .widgetLabel {
                    Text(model.appSettings.title)
                        .widgetAccentable()
                }
        } else {
            ZStack {
                AccessoryWidgetBackground()
                Gauge(value: model.appSettings.percentageDone(date: model.date)) {
                    Text(self.model.appSettings.weekdaysOnly ? "WKDY" : "DAYS")
                } currentValueLabel: {
                    Text("\(self.model.appSettings.daysLeft(model.date))")
                }
                .gaugeStyle(.accessoryCircular)
            }
        }
    }
}

@available(iOSApplicationExtension 16.0, *)
struct AccessoryCircularView_Previews: PreviewProvider {
    static var appSettings = AppSettingsDataManager(dataProvider: InMemoryDataProvider()).appSettings

    static var previews: some View {
        AccessoryCircularView(model: WidgetDaysLeftData(date: Date(), appSettings: appSettings))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
    }
}
