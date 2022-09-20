//
//  DaysLeftIntentHandler.swift
//  DaysLeftIntent
//
//  Created by John Pollard on 21/09/2018.
//  Copyright © 2018 Brave Location Software. All rights reserved.
//

import Foundation

class DaysLeftIntentHandler: NSObject, DaysLeftIntentHandling {
    
    func confirm(intent: DaysLeftIntent, completion: @escaping (DaysLeftIntentResponse) -> Void) {
        completion(DaysLeftIntentResponse(code: .ready, userActivity: nil))
    }
    
    func handle(intent: DaysLeftIntent, completion: @escaping (DaysLeftIntentResponse) -> Void) {
        let dataManager = AppSettingsDataManager()
        let appSettings = dataManager.appSettings
        let now = Date()
        
        let daysleft: NSNumber = NSNumber(value: appSettings.daysLeft(now))
        let daysType = appSettings.weekdaysOnly ? "weekdays" : "days"
        let title = appSettings.title
        
        completion(DaysLeftIntentResponse.success(daysLeft: daysleft,
                                                  daysType: daysType,
                                                  title: title))
    }
}
