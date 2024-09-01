//
//  AccessoryCircularView.swift
//  DaysLeftWidgetExtension
//
//  Created by John Pollard on 22/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import SwiftUI
import WidgetKit

#if !targetEnvironment(macCatalyst)

/// Accessory Circular View
@available(iOS 16.0, *)
struct AccessoryCircularView: View {
    /// View model
    var model: WidgetDaysLeftData
    
    /// Should we show the widget label?
    @Environment(\.showsWidgetLabel) var showsWidgetLabel
    
    /// View body
    var body: some View {
        if showsWidgetLabel {
            Gauge(value: model.displayValues.percentageDone) {
                Text(self.model.displayValues.weekdaysOnly ?
                     LocalizedStringKey("Abbreviated Weekdays") :
                     LocalizedStringKey("Abbreviated Days"))
            } currentValueLabel: {
                Text("\(self.model.displayValues.daysLeft)")
            }
            .gaugeStyle(.accessoryCircular)
            .widgetLabel {
                Text(model.displayValues.title)
                    .widgetAccentable()
            }
            .padding(1.0)
            .preferWidgetBackground(accessoryWidget: true)
        } else {
            ZStack {
                AccessoryWidgetBackground()
                Gauge(value: model.displayValues.percentageDone) {
                    Text(self.model.displayValues.weekdaysOnly ?
                         LocalizedStringKey("Abbreviated Weekdays") :
                         LocalizedStringKey("Abbreviated Days"))
                } currentValueLabel: {
                    Text("\(self.model.displayValues.daysLeft)")
                }
                .gaugeStyle(.accessoryCircular)
                .padding(1.0)
                .preferWidgetBackground(accessoryWidget: true)
            }
        }
    }
}

/// Preview provider for AccessoryCircularView
@available(iOS 16.0, *)
struct AccessoryCircularView_Previews: PreviewProvider {
    static var appSettings = AppSettingsDataManager(dataProvider: InMemoryDataProvider.shared).appSettings

    static var previews: some View {
        AccessoryCircularView(model: WidgetDaysLeftData(date: Date(), appSettings: appSettings))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
    }
}

#endif
