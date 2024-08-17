//
//  DaysLeftWatchApp.swift
//  DaysLeft WatchKit Extension
//
//  Created by John Pollard on 22/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import SwiftUI
import WatchKit
import Combine
import ClockKit
import WidgetKit
import OSLog
import AppIntents

/// Main entry point for app
@MainActor
@main struct DaysLeftWatchApp: App {
    /// Reference to extension delegate
    @WKApplicationDelegateAdaptor(ExtensionDelegate.self) var delegate
    
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
    
    init() {
        self.dataManager = AppSettingsDataManager()
        
        #if DEBUG
            #if targetEnvironment(simulator)
                self.dataManager = AppSettingsDataManager(dataProvider: InMemoryDataProvider.shared)
            #endif
        #endif
        
        self.dataModel = DaysLeftViewModel(dataManager: self.dataManager)
        
        // Setup listener for iCloud setting change
        let keyValueChangeSubscriber = NotificationCenter.default
            .publisher(for: .AppSettingsUpdated)
            .sink { _ in
                WidgetCenter.shared.reloadAllTimelines()
            }
        
        self.cancellables.append(keyValueChangeSubscriber)
        
        self.delegate.dataModel = self.dataModel
    }
    
    @Environment(\.scenePhase) private var scenePhase
    
    /// Body of app
    var body: some Scene {
        WindowGroup {
            WatchView(model: self.dataModel)
        }
        .onChange(of: scenePhase) { newScenePhase, _ in
            switch newScenePhase {
            case .active:
                self.applicationDidBecomeActive()
                
            case .inactive, .background:
                break
            @unknown default:
                self.logger.warning("Oh - interesting: I received an unexpected new value.")
            }
        }
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
    
    // MARK: Event handlers
    
    /// Event handler when iCloud key-value settings have changed
    fileprivate func iCloudSettingsUpdated() {
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
