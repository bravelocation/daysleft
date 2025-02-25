//
//  DaysLeftWidget.swift
//  DaysLeftWidget
//
//  Created by John Pollard on 08/09/2020.
//  Copyright © 2020 Brave Location Software. All rights reserved.
//

import WidgetKit
import SwiftUI

/// iOS widget
struct DaysLeftWidget: Widget {
    /// Kind of widget
    let kind: String = "DaysLeftWidget"
    
    /// Widget configuration
    var body: some WidgetConfiguration {
        return AppIntentConfiguration(
            kind: kind,
            intent: DaysLeftWidgetConfigurationIntent.self,
            provider: AppIntentWidgetTimelineProvider()) { entry in
                WidgetSwitcherView(model: entry)
            }
            .supportedFamilies(self.supportedFamilies())
            .configurationDisplayName(NSLocalizedString("Abbreviated App Title", comment: ""))
            .description(NSLocalizedString("App Title", comment: "")
        )
    }
    
    /// Supported families for the widget
    /// - Returns: Families, depending on the current platform
    private func supportedFamilies() -> [WidgetFamily] {
        if #available(iOSApplicationExtension 16.0, *) {
            #if !targetEnvironment(macCatalyst)
            return [.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular, .accessoryInline]
            #endif
        }
        
        return [.systemSmall, .systemMedium]
    }
}
