//
//  AnalyticsManager.swift
//  DaysLeft
//
//  Created by John Pollard on 02/02/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Foundation
import FirebaseAnalytics

/// Class that provides app-wide access to calling Analytics functions
public class AnalyticsManager {
    
    /// Static instance of the class
    private static let sharedInstance = AnalyticsManager()
    
    /// Shared static instance of the class, to make it easy to access across the app
    class var shared: AnalyticsManager {
        get {
            return sharedInstance
        }
    }
    
    /// Logs views of individual screens
    /// - Parameter screenName: Name of the screen
    public func logScreenView(screenName: String) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName
        ])
    }
    
#if os(iOS)
    /// Logs an message received from the watch app
    /// - Parameter messageParameters: Dictionary of additioanl parameters sent from the watch
    public func logWatchEvent(messageParameters: [String: Any]) {
        var allParameters: [String: Any] = [:]
        
        // Add the watch version to be the parameter value
        for (key, value) in messageParameters {
            if key == WatchConnectivityManager.AnalyticsValues.systemVersion.rawValue {
                allParameters[AnalyticsParameterValue] = value
            }
            
            allParameters[key] = value
        }
        
        Analytics.logEvent("watch_connected", parameters: allParameters)
    }
    #endif
}
