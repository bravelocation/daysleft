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

/// Protocol for handlers of view model actions
protocol ViewModelActionDelegate {
    /// Share event is raised
    func share()
    
    /// Edit event is raised
    func edit()
}

/// Main view model for display of days left settings
class DaysLeftViewModel: ObservableObject {
    
    /// Current display values
    @Published var displayValues: DisplayValues
    
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
        self.displayValues = DisplayValues(appSettings: self.dataManager.appSettings)
        
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
        self.displayValues = DisplayValues(appSettings: self.dataManager.appSettings)
    }
    
    /// Called when share button is tapped
    func share() {
        if let delegate = delegate {
            delegate.share()
        }
    }
    
    /// Called when edit button is tapped
    func edit() {
        if let delegate = delegate {
            delegate.edit()
        }
    }
    
    /// Formats the given date in short format
    /// - Parameter date: Date to format
    /// - Returns: String with formatted date
    func shortDateFormatted(date: Date) -> String {
        let shortDateFormatter = DateFormatter()
        shortDateFormatter.dateFormat = "EEE d MMM"
        
        return shortDateFormatter.string(from: date)
    }
    
    /// Formats the given date in a format suitable for an accessibility label
    /// - Parameter date: Date to format
    /// - Returns: String with formatted date
    func accessibilityDateFormatted(date: Date) -> String {
        let accessibilityDateFormatter = DateFormatter()
        accessibilityDateFormatter.dateFormat = "EEEE d MMM"
        
        return accessibilityDateFormatter.string(from: date)
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
