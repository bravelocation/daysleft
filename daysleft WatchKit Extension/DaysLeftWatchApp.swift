//
//  DaysLeftWatchApp.swift
//  DaysLeft WatchKit Extension
//
//  Created by John Pollard on 22/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import SwiftUI
import WatchKit

/// Main entry point for app
@main struct DaysLeftWatchApp: App {
    
    /// Reference to extension delegate
    @WKApplicationDelegateAdaptor(ExtensionDelegate.self) var delegate
    
    /// Body of app
    var body: some Scene {
        WindowGroup {
            return WatchView(model: delegate.dataModel)
        }
    }
}
