//
//  ExtensionDelegate.swift
//  daysleft
//
//  Created by John Pollard on 29/09/2015.
//  Copyright © 2015 Brave Location Software. All rights reserved.
//

import WatchKit
import Combine
import ClockKit
import WidgetKit
import OSLog
import AppIntents

/// Watch app extension delegate
@MainActor
class ExtensionDelegate: NSObject, WKApplicationDelegate {
    
    /// Logger
    private let logger = Logger(subsystem: "com.bravelocation.daysleft.v2", category: "ExtensionDelegate")
    
    /// View model for app
    var dataModel: DaysLeftViewModel?

    /// Handler for background tasks running
    /// - Parameter backgroundTasks: Set of background tasks scheduled
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        self.logger.debug("Handling background task started")

        // Mark tasks as completed
        for task in backgroundTasks {
            // If it was a background task, update widgets and setup a new one
            if task is WKApplicationRefreshBackgroundTask {
                
                // Simply update the widgets
                self.updateWidgets()
                
                // Also update the data model
                self.dataModel?.updateViewData()
                
                // Setup new refresh for tomorrow
                self.setupBackgroundRefresh()
            }
            
            task.setTaskCompletedWithSnapshot(true)
        }
    }
    
    // MARK: Event handlers
    
    /// Setup a background refresh to update data etc.
    private func setupBackgroundRefresh() {
        // Setup a background refresh for two hours time
        let twoHoursTime = Date().addingTimeInterval(2*60*60)
        
        WKApplication.shared().scheduleBackgroundRefresh(withPreferredDate: twoHoursTime,
                                                       userInfo: nil,
                                                       scheduledCompletion: { (error: Error?) in
            if let error = error {
                self.logger.debug("Error occurred while scheduling background refresh: \(error.localizedDescription)")
            }
        })
        
        self.logger.debug("Setup background task for \(twoHoursTime)")
    }
    
    /// Update any added widgets
    private func updateWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
