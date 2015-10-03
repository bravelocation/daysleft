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
        NSLog("applicationDidFinishLaunching starting")
        self.model = WatchDaysLeftModel()
        NSLog("applicationDidFinishLaunching completed")
    }
    
    func applicationDidBecomeActive() {
        NSLog("applicationDidBecomeActive started")

        // Delay setting up watch session until application is active on background queue
        let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        dispatch_async(backgroundQueue, {
            NSLog("Running watch session initialisation on background thread")
            self.model!.initialiseWatchSession()
        })
        
        NSLog("applicationDidBecomeActive completed")
    }
}
