//
//  DaysLeftWidgetBundle.swift
//  DaysLeft
//
//  Created by John Pollard on 04/08/2024.
//  Copyright © 2024 Brave Location Software. All rights reserved.
//

import WidgetKit
import SwiftUI

@main
struct DaysLeftWidgetBundle: WidgetBundle {
    var body: some Widget {
        if #available(iOS 18.0, *) {
          return iOS18Widgets
        } else {
          return iOS17Widgets
        }
    }

    @WidgetBundleBuilder
    var iOS17Widgets: some Widget {
        DaysLeftWidget()
    }

    @available(iOS 18.0, *)
    @WidgetBundleBuilder
    var iOS18Widgets: some Widget {
        DaysLeftControlWidget()
        DaysLeftWidget()
    }
}
