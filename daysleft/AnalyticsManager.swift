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
}
