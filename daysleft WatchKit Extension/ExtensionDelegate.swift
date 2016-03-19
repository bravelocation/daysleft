//
//  ExtensionDelegate.swift
//  daysleft
//
//  Created by John Pollard on 29/09/2015.
//  Copyright © 2015 Brave Location Software. All rights reserved.
//

import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    lazy var model:WatchDaysLeftModel = WatchDaysLeftModel()
        
    func applicationDidBecomeActive() {
        NSLog("applicationDidBecomeActive started")
        self.model.initialiseWatchSession()        
        NSLog("applicationDidBecomeActive completed")
    }
}
