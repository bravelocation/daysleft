//
//  WatchDaysLeftData.swift
//  daysleft WatchKit Extension
//
//  Created by John Pollard on 13/11/2019.
//  Copyright © 2019 Brave Location Software. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

protocol ViewModelActionDelegate {
    
}

class DaysLeftViewModel: ObservableObject {
    
    /// Current app settings
    @Published var appSettings: AppSettings
    
    /// Percentage done
    @Published var percentageDone: Double = 0.0
    
    /// Subscribers to change events
    private var cancellables = Array<AnyCancellable>()
    
    /// Data manager
    let dataManager: AppSettingsDataManager
    
    /// Delegate for view actions
    var delegate: ViewModelActionDelegate? = nil
    
    /// Initialiser
    /// - Parameter dataManager: Data manager
    init(dataManager: AppSettingsDataManager) {
        self.dataManager = dataManager
        self.appSettings = self.dataManager.appSettings
        
        // Setup listener for iCloud setting change
        let keyValueChangeSubscriber = NotificationCenter.default
            .publisher(for: .AppSettingsUpdated)
            .sink { _ in
                self.userSettingsUpdated()
            }
        
        self.cancellables.append(keyValueChangeSubscriber)
        
        self.updateViewData()
    }
    
    /// Update the view data on initialisation, or on a data update
    func updateViewData() {
        print("Updating view data...")
        
        // Set the published properties based on the model
        self.appSettings = self.dataManager.appSettings
        self.percentageDone = self.appSettings.percentageDone(date: Date())
    }
    
    /// Event handler for data update
    private func userSettingsUpdated() {
        print("Received UserSettingsUpdated notification")
        
        // Update view data on main thread
        DispatchQueue.main.async {
            self.updateViewData()
        }
    }
}
