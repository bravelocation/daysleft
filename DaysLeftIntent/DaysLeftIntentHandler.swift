//
//  DaysLeftIntentHandler.swift
//  DaysLeftIntent
//
//  Created by John Pollard on 21/09/2018.
//  Copyright © 2018 Brave Location Software. All rights reserved.
//

import Foundation
import daysleftlibrary

class DaysLeftIntentHandler: NSObject, DaysLeftIntentHandling {
    
    func confirm(intent: DaysLeftIntent, completion: @escaping (DaysLeftIntentResponse) -> Void) {
        completion(DaysLeftIntentResponse(code: .ready, userActivity: nil))
    }
    
    func handle(intent: DaysLeftIntent, completion: @escaping (DaysLeftIntentResponse) -> Void) {
        let model = DaysLeftModel()
        let now = Date()
        
        let daysleft:NSNumber = NSNumber(value: model.daysLeft(now))
        let daysType = model.weekdaysOnly ? "weekdays" : "days"
        let title = model.title
        
        completion(DaysLeftIntentResponse.success(daysLeft: daysleft,
                                                  daysType: daysType,
                                                  title: title))
    }
}
