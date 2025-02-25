//
//  WidgetSwitcherView.swift
//  DaysLeftWidgetExtension
//
//  Created by John Pollard on 22/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import SwiftUI

/// View that switches between views based on the widget family
struct WidgetSwitcherView: View {
    /// View model
    var model: WidgetDaysLeftData
    
    /// Current widget family
    @Environment(\.widgetFamily) var widgetFamily
    
    /// View body
    @ViewBuilder var body: some View {
        switch widgetFamily {
        case .systemSmall, .systemMedium:
            WidgetView(model: model)
#if !targetEnvironment(macCatalyst)
        case .accessoryInline:
            AccessoryInlineView(model: self.model)
        case .accessoryCircular:
            AccessoryCircularView(model: self.model)
        case .accessoryRectangular:
            AccessoryRectangularView(model: self.model)
#endif
        default:
            EmptyView()
        }
    }
}
