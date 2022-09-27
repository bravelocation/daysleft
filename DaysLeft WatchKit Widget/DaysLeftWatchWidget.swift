//
//  DaysLeft_WatchKit_Widget.swift
//  DaysLeft WatchKit Widget
//
//  Created by John Pollard on 22/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import WidgetKit
import SwiftUI

@main
struct DaysLeftWatchWidget: Widget {
    let kind: String = "DaysLeftWatchWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: WidgetTimelineProvider()) { entry in
                WatchWidgetSwitcherView(model: entry)
            }
        .supportedFamilies(self.supportedFamilies())
        .configurationDisplayName(NSLocalizedString("Abbreviated App Title", comment: ""))
        .description(NSLocalizedString("App Title", comment: ""))
    }
    
    private func supportedFamilies() -> [WidgetFamily] {
        return [.accessoryCircular, .accessoryRectangular, .accessoryInline, .accessoryCorner]
    }
}
