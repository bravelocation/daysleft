//
//  ShortcutProvider.swift
//  DaysLeft
//
//  Created by John Pollard on 22/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

#if canImport(AppIntents)
import AppIntents

@available(iOS 16, watchOS 9.0, *)
struct ShortcutsProvider: AppShortcutsProvider {
    
    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: DaysLeftAppIntent(),
            phrases: ["How Many \(.applicationName)"],
            systemImageName: "calendar.circle"
        )
    }
    
    static var shortcutTileColor: ShortcutTileColor {
        ShortcutTileColor.grayGreen
    }
}
#endif
