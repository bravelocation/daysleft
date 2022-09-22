//
//  DaysLeftWatchApp.swift
//  DaysLeft WatchKit Extension
//
//  Created by John Pollard on 22/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import SwiftUI
import WatchKit

@main
/// Main entry point for app
struct DaysLeftWatchApp: App {
    
    /// Reference to extension delegate
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            return WatchView(model: delegate.dataModel)
        }
    }
}
