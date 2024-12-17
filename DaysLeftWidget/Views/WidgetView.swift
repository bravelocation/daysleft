//
//  WidgetView.swift
//  DaysLeftWidgetExtension
//
//  Created by John Pollard on 08/09/2020.
//  Copyright © 2020 Brave Location Software. All rights reserved.
//

import Foundation
import SwiftUI
import WidgetKit

/// Main iOS widget view
struct WidgetView: View {
    
    /// View model
    var model: WidgetDaysLeftData
    
    /// Current widget family
    @Environment(\.widgetFamily) var widgetFamily
    
    /// View body
    var body: some View {
        VStack(alignment: .center) {
            Text(self.model.displayValues.fullTitle)
                .lineLimit(2)
                .allowsTightening(true)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            CircularProgressView(
                progress: self.model.displayValues.percentageDone,
                lineWidth: widgetFamily == .systemSmall ? 16.0 : 24.0
            )
            .padding([.top, .bottom], widgetFamily == .systemSmall ? 12.0 : 16.0)
            
            Text(self.model.displayValues.currentPercentageLeft)
                .font(.footnote)

        }
        .preferWidgetBackground()
    }
}

/// Preview provider for WidgetView
struct WidgetView_Previews: PreviewProvider {
    static var appSettings = AppSettingsDataManager(dataProvider: InMemoryDataProvider.shared).appSettings
    
    static var previews: some View {
        Group {
            WidgetView(model: WidgetDaysLeftData(date: Date(), appSettings: appSettings))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            WidgetView(model: WidgetDaysLeftData(date: Date(), appSettings: appSettings))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        
            WidgetView(model: WidgetDaysLeftData(date: Date(), appSettings: appSettings))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .environment(\.colorScheme, .dark)
            WidgetView(model: WidgetDaysLeftData(date: Date(), appSettings: appSettings))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .environment(\.colorScheme, .dark)
        }
    }
}
