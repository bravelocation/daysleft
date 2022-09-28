//
//  AppControlSettings.swift
//  DaysLeft
//
//  Created by John Pollard on 20/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Foundation

/// Current settings used in control of the app
struct AppControlSettings {
    /// The firstRun value (integer for legacy reasons!)
    let firstRun: Int
    
    /// Show badge flag
    let showBadge: Bool
}
