//
//  WatchWidgetSwitcherView.swift
//  DaysLeft WatchKit WidgetExtension
//
//  Created by John Pollard on 22/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import SwiftUI

/// View that switches view based on widget family
struct WatchWidgetSwitcherView: View {
    /// View model
    var model: WidgetDaysLeftData
    
    /// Current widget family
    @Environment(\.widgetFamily) var widgetFamily
    
    /// View body
    @ViewBuilder var body: some View {
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
