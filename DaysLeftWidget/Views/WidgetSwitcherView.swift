//
//  WidgetSwitcherView.swift
//  DaysLeftWidgetExtension
//
//  Created by John Pollard on 22/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import SwiftUI

struct WidgetSwitcherView: View {
    var model: WidgetDaysLeftData
    @Environment(\.widgetFamily) var widgetFamily
    
    @ViewBuilder
    var body: some View {
        switch widgetFamily {
        case .systemSmall, .systemMedium:
            WidgetView(model: model)
#if !targetEnvironment(macCatalyst)
        case .accessoryInline:
            if #available(iOSApplicationExtension 16.0, *) {
                AccessoryInlineView(model: self.model)
            }
        case .accessoryCircular:
            if #available(iOSApplicationExtension 16.0, *) {
                AccessoryCircularView(model: self.model)
            }
        case .accessoryRectangular:
            if #available(iOSApplicationExtension 16.0, *) {
                AccessoryRectangularView(model: self.model)
            }
#endif
        default:
            EmptyView()
        }
    }
}
