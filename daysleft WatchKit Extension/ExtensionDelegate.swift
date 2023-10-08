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

/// Watch app extension delegate
class ExtensionDelegate: NSObject, WKApplicationDelegate {
    
    /// Data manager
    private var dataManager: AppSettingsDataManager
    
    /// View model for app
    let dataModel: DaysLeftViewModel
    
    /// Watch connectivity manager
    private let watchConnectivityManager = WatchConnectivityManager()
    
    /// Subscribers to change events
    private var cancellables = [AnyCancellable]()
    
    // MARK: Initialisation
    
    /// Initialiser
    override init() {
        
        self.dataManager = AppSettingsDataManager()
        
        #if DEBUG
            #if targetEnvironment(simulator)
                self.dataManager = AppSettingsDataManager(dataProvider: InMemoryDataProvider.shared)
            #endif
        #endif
        
        self.dataModel = DaysLeftViewModel(dataManager: self.dataManager)
        
        super.init()
        
        // Setup listener for iCloud setting change
        let keyValueChangeSubscriber = NotificationCenter.default
            .publisher(for: .AppSettingsUpdated)
            .sink { _ in
                self.iCloudSettingsUpdated()
            }
        
        self.cancellables.append(keyValueChangeSubscriber)
    }
    
    /// Delegate when watch becomes active
    func applicationDidBecomeActive() {
        print("applicationDidBecomeActive started")
        
        // Setup connection with the phone app
        self.watchConnectivityManager.setupConnection()
        
        // Update the data model
        self.dataModel.updateViewData()
        
        // Setup background refresh
        self.setupBackgroundRefresh()
        
        // Update complications
        self.updateComplications()
        
        print("applicationDidBecomeActive completed")
    }
    
    /// Handelr for background tasks running
    /// - Parameter backgroundTasks: Set of background tasks scheduled
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        print("Handling background task started")

        // Mark tasks as completed
        for task in backgroundTasks {
            // If it was a background task, update complications and setup a new one
            if task is WKApplicationRefreshBackgroundTask {
                
                // Simply update the complications on a background task being triggered
                self.updateComplications()
                
                // Also update the data model
                self.dataModel.updateViewData()
                
                // Setup new refresh for tomorrow
                self.setupBackgroundRefresh()
            }
            
            task.setTaskCompletedWithSnapshot(true)
        }
    }
    
    // MARK: Event handlers
    
    /// Event handler when iCloud key-value settings have changed
    @objc fileprivate func iCloudSettingsUpdated() {
        print("Received iCloudSettingsUpdated notification")
        
        // Update complications
        self.updateComplications()
    }
    
    /// Setup a background refresh to update data etc.
    private func setupBackgroundRefresh() {
        // Setup a background refresh for two hours time
        let twoHoursTime = Date().addingTimeInterval(2*60*60)
        
        WKApplication.shared().scheduleBackgroundRefresh(withPreferredDate: twoHoursTime,
                                                       userInfo: nil,
                                                       scheduledCompletion: { (error: Error?) in
            if let error = error {
                print("Error occurred while scheduling background refresh: \(error.localizedDescription)")
            }
        })
        
        print("Setup background task for \(twoHoursTime)")
    }
    
    /// Update any added complications
    private func updateComplications() {
        let complicationServer = CLKComplicationServer.sharedInstance()
        
        if let activeComplications = complicationServer.activeComplications {
            for complication in activeComplications {
                complicationServer.reloadTimeline(for: complication)
            }
        }
        
        // Should we be updating widgets too?
        WidgetCenter.shared.reloadAllTimelines()
    }
}
