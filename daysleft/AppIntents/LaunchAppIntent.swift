//
//  LaunchAppIntent.swift
//  DaysLeft
//
//  Created by John Pollard on 04/08/2024.
//  Copyright © 2024 Brave Location Software. All rights reserved.
//

import AppIntents
import UIKit

struct LaunchAppIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Days Left"
    static let description = IntentDescription("Open Days Left")
    static let openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
