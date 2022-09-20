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
        let now = Date()
        
        let daysleft: NSNumber = NSNumber(value: dataManager.daysLeft(now))
        let daysType = dataManager.weekdaysOnly ? "weekdays" : "days"
        let title = dataManager.title
        
        completion(DaysLeftIntentResponse.success(daysLeft: daysleft,
                                                  daysType: daysType,
                                                  title: title))
    }
}
