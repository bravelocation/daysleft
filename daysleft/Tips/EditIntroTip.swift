//
//  EditIntroTip.swift
//  DaysLeft
//
//  Created by John Pollard on 25/02/2025.
//  Copyright © 2025 Brave Location Software. All rights reserved.
//

import TipKit

struct EditIntroTip: Tip {
    static let settingsOpenedCount: Event = Event(id: "settingsOpenedCount")
    
    var title: Text {
        Text("Change Countdown Settings")
    }
    
    var message: Text? {
        Text("Change what you are counting down to via the Edit button")
    }
    
    var options: [TipOption] {
        [Tip.MaxDisplayCount(2)]
    }
    
    var rules: [Rule] {
        [
            #Rule(Self.settingsOpenedCount) {
                $0.donations.count < 1
            }
        ]
    }
    
    var image: Image? {
        return nil
    }
}
