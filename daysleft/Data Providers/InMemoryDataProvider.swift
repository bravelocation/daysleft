//
//  InMemoryDataProvider.swift
//  DaysLeftTests
//
//  Created by John Pollard on 20/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Foundation

/// Class that provides simple in-memory data - used soley for previews and unit tests
class InMemoryDataProvider: DataProviderProtocol {
    
    /// Static instance of the class
    private static let sharedInstance = InMemoryDataProvider()
    
    /// Shared static instance of the class, to make it easy to access across the app
    class var shared: InMemoryDataProvider {
        get {
            return sharedInstance
        }
    }
    
    /// Initialiser
    private init() {
        // Set some initial settings
        self.settingsCache["start"] = Date().addingTimeInterval(-20*24*60*60)
        self.settingsCache["end"] = Date.nextXmas()
        self.settingsCache["title"] = "Christmas"
        self.settingsCache["weekdaysOnly"] = false
        self.settingsCache["firstRun"] = 1
        self.settingsCache["showBadge"] = false
    }
    
    /// Settings cache used to store settings locally for faster access
    private var settingsCache = Dictionary<String, Any>()
    
    // MARK: - DataProviderProtocol implementation
    
    /// Used to read an object setting from the setting store
    ///
    /// - Parameter key: The key for the setting
    /// - Returns: An AnyObject? value retrieved from the settings store
    func readObjectFromStore<T>(_ key: String, defaultValue: T) -> T {
        if let userSettingsValue = self.settingsCache[key] as? T {
            return userSettingsValue
        }
        
        return defaultValue
    }
    
    /// Used to write an Object setting to the user setting store
    ///
    /// - Parameters:
    ///     - value: The value for the setting
    ///     - key: The key for the setting
    func writeObjectToStore<T>(_ value: T, key: String) {
        self.settingsCache[key] = value
        
        // Send a notification for the view controllers to refresh
        NotificationCenter.default.post(name: .AppSettingsUpdated, object: nil)
    }
    
    /// Synchronises data with the remote data store
    func synchronise() {
        // No need to do anything on an in-memory sync
    }
}
