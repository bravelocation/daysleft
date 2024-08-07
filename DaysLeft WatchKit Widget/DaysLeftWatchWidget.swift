//
//  DaysLeft_WatchKit_Widget.swift
//  DaysLeft WatchKit Widget
//
//  Created by John Pollard on 22/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import WidgetKit
import SwiftUI

/// Watch extension widget
@main struct DaysLeftWatchWidget: Widget {
    /// Widget kind
    let kind: String = "DaysLeftWatchWidget"
    
    /// Configuration body
    var body: some WidgetConfiguration {
        if #available(watchOS 10.0, *) {
            return AppIntentConfiguration(
                kind: kind,
                intent: DaysLeftWidgetConfigurationIntent.self,
                provider: AppIntentWidgetTimelineProvider()) { entry in
                    WatchWidgetSwitcherView(model: entry)
                }
                .supportedFamilies(self.supportedFamilies())
                .configurationDisplayName(NSLocalizedString("Abbreviated App Title", comment: ""))
                .description(NSLocalizedString("App Title", comment: "")
            )
        } else {
            return StaticConfiguration(
                kind: kind,
                provider: WidgetTimelineProvider()) { entry in
                    WatchWidgetSwitcherView(model: entry)
                }
                .supportedFamilies(self.supportedFamilies())
                .configurationDisplayName(NSLocalizedString("Abbreviated App Title", comment: ""))
                .description(NSLocalizedString("App Title", comment: "")
            )
        }
    }
    
    /// Supported fwidget families
    /// - Returns: Array of supported families
    private func supportedFamilies() -> [WidgetFamily] {
        return [.accessoryCircular, .accessoryRectangular, .accessoryInline, .accessoryCorner]
    }
}
