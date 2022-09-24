//
//  InMemoryDataProvider.swift
//  DaysLeftTests
//
//  Created by John Pollard on 20/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Foundation

class InMemoryDataProvider: DataProviderProtocol {
    
    init() {
        // Set some initial settings
        self.settingsCache["start"] = Date().addingTimeInterval(-20*24*60*60)
        self.settingsCache["end"] = Date.nextXmas()
        self.settingsCache["title"] = "Testing"
        self.settingsCache["weekdaysOnly"] = false
        self.settingsCache["firstRun"] = 1
    }
    
    /// Settings cache used to store settings locally for faster access
    private var settingsCache = Dictionary<String, Any>()
    
    /// Used to read an object setting from the setting store
    ///
    /// param: key The key for the setting
    /// returns: An AnyObject? value retrieved from the settings store
    func readObjectFromStore(_ key: String) -> Any? {
        return self.settingsCache[key]
    }
    
    /// Used to write an Object setting to the user setting store
    ///
    /// param: value The value for the setting
    /// param: key The key for the setting
    func writeObjectToStore(_ value: AnyObject, key: String) {
        self.settingsCache[key] = value
    }
    
    /// Synchronises data with the remote data store
    func synchronise() {
        // No need to do anything on an in-memory sync
    }
}
