//
//  DaysLeftApp.swift
//  DaysLeft
//
//  Created by John Pollard on 13/03/2025.
//  Copyright © 2025 Brave Location Software. All rights reserved.
//

import SwiftUI
import OSLog
import TipKit
import AppIntents

@main
/// Main entry point for app
struct DaysLeftApp: App {
    
    /// App delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @Environment(\.scenePhase) private var scenePhase
    
    /// Logger
    private let logger = Logger(subsystem: "com.bravelocation.daysleft.v2", category: "DaysLeftApp")


    /// App data manager
    let dataManager = AppSettingsDataManager()
    
    init() {
        // Setup TipKit
        try? Tips.configure([
            .displayFrequency(.daily)
        ])
    }
    
    var body: some Scene {
        WindowGroup {
            MainView(model: self.viewModel)
        }
        .onChange(of: scenePhase) { newScenePhase, _ in
            switch newScenePhase {
            case .active:
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
                
            case .inactive, .background:
                break
            @unknown default:
                self.logger.warning("Oh - interesting: I received an unexpected new value.")
            }
        }
    }
    
    private var viewModel: DaysLeftViewModel {
        // If running UI tests or in the simulator, use the InMemoryDataProvider
        #if DEBUG
        if CommandLine.arguments.contains("-enable-ui-testing") || UIDevice.isSimulator {
            return DaysLeftViewModel(dataManager: AppSettingsDataManager(dataProvider: InMemoryDataProvider.shared))
        }
        #endif
        
        return DaysLeftViewModel(dataManager: self.dataManager)
    }
}
