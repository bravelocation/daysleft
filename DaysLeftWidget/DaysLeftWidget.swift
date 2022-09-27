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
                WidgetSwitcherView(model: entry)
            }
        .supportedFamilies(self.supportedFamilies())
        .configurationDisplayName(NSLocalizedString("Abbreviated App Title", comment: ""))
        .description(NSLocalizedString("App Title", comment: ""))
    }
    
    private func supportedFamilies() -> [WidgetFamily] {
        if #available(iOSApplicationExtension 16.0, *) {
            #if !targetEnvironment(macCatalyst)
            return [.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular, .accessoryInline]
            #endif
        }
        
        return [.systemSmall, .systemMedium]
    }
}
