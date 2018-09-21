//
//  IntentHandler.swift
//  DaysLeftIntent
//
//  Created by John Pollard on 21/09/2018.
//  Copyright © 2018 Brave Location Software. All rights reserved.
//

import Intents
import daysleftlibrary

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        guard intent is DaysLeftIntent else {
            fatalError("Unhandled intent type: \(intent)")
        }
        
        return DaysLeftIntentHandler()
    }
    
}
