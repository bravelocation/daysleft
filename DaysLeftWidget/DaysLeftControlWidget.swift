//
//  DaysLeftControlWidget.swift
//  DaysLeft
//
//  Created by John Pollard on 04/08/2024.
//  Copyright © 2024 Brave Location Software. All rights reserved.
//

import WidgetKit
import SwiftUI

@available(iOS 18.0, *)
struct DaysLeftControlWidget: ControlWidget {
    
    static let kind: String = "com.bravelocation.daysleft.v2.DaysLeftControlWidget"
    
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: Self.kind,
            provider: DaysLeftValueProvider()
        ) { daysLeft in
            ControlWidgetButton(action: LaunchAppIntent()) {
                Label(daysLeft.displayValues.fullTitle,
                      systemImage: daysLeft.displayValues.daysLeft <= 50 ?
                      "\(daysLeft.displayValues.daysLeft).circle" : "x.circle")
            }
        }
        .displayName("Days Left")
        .description("How many days left?")
    }
}
