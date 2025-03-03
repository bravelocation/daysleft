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
struct AccessoryCircularView: View {
    /// View model
    var model: WidgetDaysLeftData
    
    /// Should we show the widget label?
    @Environment(\.showsWidgetLabel) var showsWidgetLabel
    
    /// View body
    var body: some View {
        let percentageDone = model.displayValues.percentageDone
        let gradientColors = [
            Color("MainAppColor"),
            Color("MainAppColor").opacity(0.5),
            Color("LightAppColor"),
        ]
        
        let gaugeGradient = Gradient(stops: [
            .init(color: gradientColors[0], location: 0),
            .init(color: gradientColors[1], location: CGFloat(percentageDone)),
            .init(color: gradientColors[2], location: 1)
        ])
        
        let textColor = Color("LightAppColor")
        
        if showsWidgetLabel {
            Gauge(value: model.displayValues.percentageDone) {
                Text(self.model.displayValues.weekdaysOnly ?
                     LocalizedStringKey("Abbreviated Weekdays") :
                     LocalizedStringKey("Abbreviated Days"))
            } currentValueLabel: {
                Text("\(self.model.displayValues.daysLeft)")
                    .foregroundColor(textColor)
            }
            .gaugeStyle(.accessoryCircular)
            .tint(gaugeGradient)
            .widgetLabel {
                Text(model.displayValues.title)
                    .foregroundColor(textColor)
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
                    .foregroundColor(textColor)
                } currentValueLabel: {
                    Text("\(self.model.displayValues.daysLeft)")
                        .foregroundColor(textColor)
                }
                .gaugeStyle(.accessoryCircular)
                .tint(gaugeGradient)
                .padding(1.0)
                .preferWidgetBackground(accessoryWidget: true)
            }
        }
    }
}

/// Preview provider for AccessoryCircularView
struct AccessoryCircularView_Previews: PreviewProvider {
    static var appSettings = AppSettingsDataManager(dataProvider: InMemoryDataProvider.shared).appSettings

    static var previews: some View {
        AccessoryCircularView(model: WidgetDaysLeftData(date: Date(), appSettings: appSettings))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
    }
}

#endif
