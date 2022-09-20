//
//  AppSettings.swift
//  DaysLeft
//
//  Created by John Pollard on 20/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Foundation

/// Current app settings
struct AppSettings {
    /// Start date
    let start: Date
    
    /// End date
    let end: Date
    
    /// Title
    let title: String
    
    /// Use weekdays only?
    let weekdaysOnly: Bool
}
