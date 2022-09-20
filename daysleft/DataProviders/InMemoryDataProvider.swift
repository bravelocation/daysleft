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
        self.settingsCache["firstRun"] = 0
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
}
