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
        self.logger.debug("applicationDidBecomeActive started")
        
        // Setup connection with the phone app
        self.watchConnectivityManager.setupConnection()
        
        // Update the data model
        self.dataModel.updateViewData()
        
        // Setup background refresh
        self.setupBackgroundRefresh()
        
        // Update widgets
        self.updateWidgets()
        
        // Donate any intents for smart stack optimisation
        self.donateIntent()
        
        self.logger.debug("applicationDidBecomeActive completed")
    }
    
    /// Handelr for background tasks running
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
        self.logger.debug("Received iCloudSettingsUpdated notification")
        
        // Update widgets
        self.updateWidgets()
    }
    
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
    
    
    // MARK: - Intent functions
    /// Donates app intent to help smart stack inteliigence for widget
    func donateIntent() {
        if #available(watchOS 10, *) {
            // Donate the widget intent to help smart stack intelligence
            IntentDonationManager.shared.donate(intent: DaysLeftWidgetConfigurationIntent())
            
            // Also update the relevance time for the length of the countdown
            Task {
               let relevantContext: RelevantContext = .date(from: self.dataManager.appSettings.start, to: self.dataManager.appSettings.end)
               let relevantIntent = RelevantIntent(
                   DaysLeftWidgetConfigurationIntent(),
                   widgetKind: "DaysLeftWidget",
                   relevance: relevantContext)
               
                try await RelevantIntentManager.shared.updateRelevantIntents([relevantIntent])
            }
        }
    }
}
