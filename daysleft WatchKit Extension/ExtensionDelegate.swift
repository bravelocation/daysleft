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
                
        // Initialise the watch session
        self.model.initialiseWatchSession()
        
        // Setup background refresh
        self.setupBackgroundRefresh()
        
        NSLog("applicationDidBecomeActive completed")
    }
    
    func handleBackgroundTasks(backgroundTasks: Set<WKRefreshBackgroundTask>) {
        print("Handling background task started")

        // Mark tasks as completed
        for task in backgroundTasks {
            // If it was a background task, update complications and setup a new one
            if (task is WKApplicationRefreshBackgroundTask) {
                
                // Simply update the complications on a background task being triggered
                self.model.updateComplications()
                
                // Setup new refresh for tomorrow
                self.setupBackgroundRefresh()
            }
            
            task.setTaskCompleted()
        }
    }
    
    func setupBackgroundRefresh() {
        // Setup a background refresh for 0100 tomorrow
        let globalCalendar = NSCalendar.autoupdatingCurrentCalendar()
        let twoHoursTime = globalCalendar.dateByAddingUnit(.Hour, value: 2, toDate: NSDate(), options: [])
        
        WKExtension.sharedExtension().scheduleBackgroundRefreshWithPreferredDate(twoHoursTime!, userInfo: nil, scheduledCompletion: { (error: NSError?) in
            if let error = error {
                print("Error occurred while scheduling background refresh: \(error.localizedDescription)")
            }
        })
        
        print("Setup background task for \(twoHoursTime)")
    }
}
