//
//  ShortcutProvider.swift
//  DaysLeft
//
//  Created by John Pollard on 22/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

#if canImport(AppIntents)
import AppIntents

/// Provides preset shortcuts automatically from the app
@available(iOS 16, watchOS 9.0, *)
struct ShortcutsProvider: AppShortcutsProvider {
    
    @AppShortcutsBuilder
    /// Provided shortcuts
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: DaysLeftAppIntent(),
            phrases: ["How Many \(.applicationName)"],
            systemImageName: "calendar.circle"
        )
    }
    
    /// The background color of the tile that Shortcuts displays for each of the app’s App Shortcuts.
    static var shortcutTileColor: ShortcutTileColor {
        ShortcutTileColor.grayGreen
    }
}
#endif
