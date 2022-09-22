//
//  WatchWidgetSwitcherView.swift
//  DaysLeft WatchKit WidgetExtension
//
//  Created by John Pollard on 22/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import SwiftUI

struct WatchWidgetSwitcherView: View {
    var model: WidgetDaysLeftData
    @Environment(\.widgetFamily) var widgetFamily
    
    @ViewBuilder
    var body: some View {
        switch widgetFamily {
        case .accessoryInline:
            AccessoryInlineView(model: self.model)
        case .accessoryCircular:
            AccessoryCircularView(model: self.model)
        case .accessoryRectangular:
            AccessoryRectangularView(model: self.model)
        case .accessoryCorner:
            AccessoryCircularView(model: self.model)
        default:
            EmptyView()
        }
    }
}
