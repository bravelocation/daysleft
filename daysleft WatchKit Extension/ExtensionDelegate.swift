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

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    /// View model for app
    var dataModel = DaysLeftViewModel(dataManager: AppSettingsDataManager())
    
    /// Subscribers to change events
    private var cancellables = Array<AnyCancellable>()
    
    // MARK: Initialisation
    override init() {
        super.init()
        
        // Setup listener for iCloud setting change
        let keyValueChangeSubscriber = NotificationCenter.default
            .publisher(for: .AppSettingsUpdated)
            .sink { _ in
                self.iCloudSettingsUpdated()
            }
        
        self.cancellables.append(keyValueChangeSubscriber)
    }

    func applicationDidBecomeActive() {
        print("applicationDidBecomeActive started")
        
        // Update the data model
        self.dataModel.updateViewData()
        
        // Setup background refresh
        self.setupBackgroundRefresh()
        
        print("applicationDidBecomeActive completed")
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        print("Handling background task started")

        // Mark tasks as completed
        for task in backgroundTasks {
            // If it was a background task, update complications and setup a new one
            if (task is WKApplicationRefreshBackgroundTask) {
                
                // Simply update the complications on a background task being triggered
                let complicationServer = CLKComplicationServer.sharedInstance()
                let activeComplications = complicationServer.activeComplications
                
                if (activeComplications != nil) {
                    for complication in activeComplications! {
                        complicationServer.reloadTimeline(for: complication)
                    }
                }
                
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
    
    
    // MARK: Event handlers
    @objc
    fileprivate func iCloudSettingsUpdated() {
        print("Received iCloudSettingsUpdated notification")
        
        // Update complications
        self.updateComplications()
    }
    
    private func setupBackgroundRefresh() {
        // Setup a background refresh for 0100 tomorrow
        let twoHoursTime = Calendar.current.date(byAdding: .hour, value: 2, to: Date())
        
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: twoHoursTime!, userInfo: nil, scheduledCompletion: { (error: Error?) in
            if let error = error {
                print("Error occurred while scheduling background refresh: \(error.localizedDescription)")
            }
        })
        
        print("Setup background task for \(String(describing: twoHoursTime))")
    }
    
    /// Update any added complications
    private func updateComplications() {
        let complicationServer = CLKComplicationServer.sharedInstance()
        let activeComplications = complicationServer.activeComplications
        
        if (activeComplications != nil) {
            for complication in activeComplications! {
                complicationServer.reloadTimeline(for: complication)
            }
        }
    }
}
