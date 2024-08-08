//
//  WidgetConfigurationIntent.swift
//  DaysLeft
//
//  Created by John Pollard on 07/08/2024.
//  Copyright © 2024 Brave Location Software. All rights reserved.
//

import AppIntents
import WidgetKit

@available(iOS 17, watchOS 10, *)
struct DaysLeftWidgetConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configure Days Left"
    static var description = IntentDescription("Configure Days Left")
    static var openAppWhenRun: Bool = false
    static var isDiscoverable: Bool = false

    init() {
       // Placeholder initialiser
    }
}
