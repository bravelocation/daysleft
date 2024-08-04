//
//  LaunchAppIntent.swift
//  DaysLeft
//
//  Created by John Pollard on 04/08/2024.
//  Copyright © 2024 Brave Location Software. All rights reserved.
//

import AppIntents
import UIKit

@available(iOS 16, *)
struct LaunchAppIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Days Left"
    static var description = IntentDescription("Open Days Left")
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
