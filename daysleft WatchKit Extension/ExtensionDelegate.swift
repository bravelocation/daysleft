//
//  ExtensionDelegate.swift
//  daysleft
//
//  Created by John Pollard on 29/09/2015.
//  Copyright © 2015 Brave Location Software. All rights reserved.
//

import WatchKit
import daysleftlibrary

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    var model:WatchDaysLeftModel?
    
    func applicationDidFinishLaunching() {
        self.model = WatchDaysLeftModel()
    }
    
    func applicationDidBecomeActive() {
        
        // Delay setting up watch session until application is active
        self.model!.initialiseWatchSession()
        
        print("applicationDidBecomeActive")
    }
    
    func applicationWillResignActive() {
        print("applicationWillResignActive")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
}
