//
//  SettingsManager.swift
//  daysleft
//
//  Created by John Pollard on 24/09/2018.
//  Copyright © 2018 Brave Location Software. All rights reserved.
//

import Foundation

public class SettingsManager {
    fileprivate static let sharedInstance = SettingsManager()
    class var instance: SettingsManager {
        get {
            return sharedInstance
        }
    }
    
    private var settings: NSDictionary
    
    init() {
        if let path = Bundle.main.path(forResource: "Settings", ofType: "plist") {
            self.settings = NSDictionary(contentsOfFile: path)!
        } else {
            self.settings = NSDictionary()
        }
    }
    
    public func getSetting(_ key: String) -> Any? {
        return self.settings[key]
    }
}
