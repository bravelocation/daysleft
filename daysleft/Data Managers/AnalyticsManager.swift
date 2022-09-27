//
//  AnalyticsManager.swift
//  DaysLeft
//
//  Created by John Pollard on 02/02/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Foundation
import FirebaseAnalytics

public class AnalyticsManager {
    
    private static let sharedInstance = AnalyticsManager()
                                    
    class var shared: AnalyticsManager {
        get {
            return sharedInstance
        }
    }
    
    public func logScreenView(screenName: String) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName
        ])
    }
    
    #if os(iOS)
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
