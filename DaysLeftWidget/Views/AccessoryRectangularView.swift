//
//  AccessoryRectangularView.swift
//  DaysLeftWidgetExtension
//
//  Created by John Pollard on 22/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 16.0, *)
struct AccessoryRectangularView: View {
    var model: WidgetDaysLeftData
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(self.model.appSettings.title)
                .widgetAccentable()
            
            Text("\(self.model.appSettings.daysLeftDescription(model.date)) left")
            Text(self.model.appSettings.currentPercentageLeft(date: model.date))
                .font(.footnote)
        }
    }
}

@available(iOSApplicationExtension 16.0, *)
struct AccessoryRectangularView_Previews: PreviewProvider {
    static var appSettings = AppSettingsDataManager(dataProvider: InMemoryDataProvider()).appSettings

    static var previews: some View {
        AccessoryRectangularView(model: WidgetDaysLeftData(date: Date(), appSettings: appSettings))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
