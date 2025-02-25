//
//  WidgetConfigurationIntent.swift
//  DaysLeft
//
//  Created by John Pollard on 07/08/2024.
//  Copyright © 2024 Brave Location Software. All rights reserved.
//

import AppIntents
import WidgetKit

struct DaysLeftWidgetConfigurationIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Configure Days Left"
    static let description = IntentDescription("Configure Days Left")
    static let openAppWhenRun: Bool = false
    static let isDiscoverable: Bool = false

    init() {
       // Placeholder initialiser
    }
}
