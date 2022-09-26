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

struct WidgetView: View {
    
    var model: WidgetDaysLeftData
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        VStack(alignment: .center) {
            Text(self.model.displayValues.fullTitle)
                .lineLimit(2)
                .allowsTightening(true)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(Color.primary)
            
            CircularProgressView(
                progress: self.model.displayValues.percentageDone,
                lineWidth: widgetFamily == .systemSmall ? 12.0 : 20.0
            )
            .padding([.top, .bottom], widgetFamily == .systemSmall ? 8.0 : 16.0)
            
            Text(self.model.displayValues.currentPercentageLeft)
                .font(.footnote)
                .foregroundColor(Color.primary)
        }
        .padding()
    }
}

struct WidgetView_Previews: PreviewProvider {
    static var appSettings = AppSettingsDataManager(dataProvider: InMemoryDataProvider()).appSettings
    
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
