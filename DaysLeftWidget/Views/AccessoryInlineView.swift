//
//  AccessoryInlineView.swift
//  DaysLeftWidgetExtension
//
//  Created by John Pollard on 22/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import SwiftUI
import WidgetKit

#if !targetEnvironment(macCatalyst)

/// Accessory inline view
@available(iOS 16.0, *)
struct AccessoryInlineView: View {
    /// View model
    var model: WidgetDaysLeftData
    
    /// View body
    var body: some View {
        Text(model.displayValues.fullTitle)
            .preferWidgetBackground(accessoryWidget: true)
    }
}

/// Preview provider for AccessoryInlineView
@available(iOS 16.0, *)
struct AccessoryInlineView_Previews: PreviewProvider {
    static var appSettings = AppSettingsDataManager(dataProvider: InMemoryDataProvider.shared).appSettings

    static var previews: some View {
        AccessoryInlineView(model: WidgetDaysLeftData(date: Date(), appSettings: appSettings))
            .previewContext(WidgetPreviewContext(family: .accessoryInline))
    }
}

#endif
