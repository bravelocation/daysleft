//
//  AccessoryInlineView.swift
//  DaysLeftWidgetExtension
//
//  Created by John Pollard on 22/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 16.0, *)
struct AccessoryInlineView: View {
    var model: WidgetDaysLeftData
    
    var body: some View {
        Text(model.displayValues.fullTitle)
    }
}

@available(iOSApplicationExtension 16.0, *)
struct AccessoryInlineView_Previews: PreviewProvider {
    static var appSettings = AppSettingsDataManager(dataProvider: InMemoryDataProvider()).appSettings

    static var previews: some View {
        AccessoryInlineView(model: WidgetDaysLeftData(date: Date(), appSettings: appSettings))
            .previewContext(WidgetPreviewContext(family: .accessoryInline))
    }
}
