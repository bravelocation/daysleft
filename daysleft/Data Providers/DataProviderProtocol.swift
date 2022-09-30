//
//  DataProviderProtocol.swift
//  DaysLeft
//
//  Created by John Pollard on 20/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Foundation

/// Protocol for app data providers
protocol DataProviderProtocol {
    
    /// Used to read an object setting from the setting store
    ///
    /// - Parameter key: The key for the setting
    /// - Returns: An AnyObject? value retrieved from the settings store
    func readObjectFromStore<T>(_ key: String, defaultValue: T) -> T
    
    /// Used to write a setting to the user setting store
    ///
    /// - Parameters:
    ///     - value: The value for the setting
    ///     - key: The key for the setting
    func writeObjectToStore<T>(_ value: T, key: String)
    
    /// Synchronises data with the remote data store
    func synchronise()
}
