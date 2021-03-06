//
//  ExtensionDelegate.swift
//  daysleft
//
//  Created by John Pollard on 29/09/2015.
//  Copyright © 2015 Brave Location Software. All rights reserved.
//

import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    lazy var model: WatchDaysLeftModel = WatchDaysLeftModel()
    lazy var dataModel: WatchDaysLeftData = WatchDaysLeftData()

    func applicationDidBecomeActive() {
        NSLog("applicationDidBecomeActive started")
                
        // Initialise the watch session
        self.model.initialiseWatchSession()
        
        // Update the data model
        self.dataModel.updateViewData()
        
        // Setup background refresh
        self.setupBackgroundRefresh()
        
        NSLog("applicationDidBecomeActive completed")
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        print("Handling background task started")

        // Mark tasks as completed
        for task in backgroundTasks {
            // If it was a background task, update complications and setup a new one
            if (task is WKApplicationRefreshBackgroundTask) {
                
                // Simply update the complications on a background task being triggered
                self.model.updateComplications()
                
                // Also update the data model
                self.dataModel.updateViewData()
                
                // Setup new refresh for tomorrow
                self.setupBackgroundRefresh()
            }
            
            task.setTaskCompletedWithSnapshot(true)
        }
    }
    
    func handle(_ userActivity: NSUserActivity) {
        print("Handling user activity")
        // Not sure what to do here
    }
    
    private func setupBackgroundRefresh() {
        // Setup a background refresh for 0100 tomorrow
        let globalCalendar = Calendar.autoupdatingCurrent
        let twoHoursTime = (globalCalendar as NSCalendar).date(byAdding: .hour, value: 2, to: Date(), options: [])
        
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: twoHoursTime!, userInfo: nil, scheduledCompletion: { (error: Error?) in
            if let error = error {
                print("Error occurred while scheduling background refresh: \(error.localizedDescription)")
            }
        })
        
        print("Setup background task for \(String(describing: twoHoursTime))")
    }
}
