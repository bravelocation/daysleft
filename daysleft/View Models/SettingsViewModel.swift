//
//  SettingsViewModel.swift
//  DaysLeft
//
//  Created by John Pollard on 21/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Foundation
import Combine

protocol SettingsActionDelegate {
    func badgeChanged()
}

/// Settings view model
class SettingsViewModel: ObservableObject {
    var appSettings: AppSettings
    
    /// Delegate for view actions
    var delegate: SettingsActionDelegate? = nil
    
    /// Data manager
    private let dataManager: AppSettingsDataManager
    
    /// Initialiser
    /// - Parameter dataManager: Data manager
    init(dataManager: AppSettingsDataManager) {
        self.dataManager = dataManager
        self.appSettings = self.dataManager.appSettings
    }
    
    /// Update the start date
    /// - Parameter date: New start date
    func updateStartDate(_ date: Date) {
        self.dataManager.updateStartDate(date)
    }
    
    /// Update the end date
    /// - Parameter date: New end date
    func updateEndDate(_ date: Date) {
        self.dataManager.updateEndDate(date)
    }
    
    /// Update the title
    /// - Parameter title: New title
    func updateTitle(_ title: String) {
        self.dataManager.updateTitle(title)
    }
    
    /// Update weekdays only
    /// - Parameter on: New weekdays only
    func updateWeekdaysOnly(_ on: Bool) {
        self.dataManager.updateWeekdaysOnly(on)
    }
    
    /// Update show badge
    /// - Parameter on: New show badge
    func updateShowBadge(_ on: Bool) {
        self.dataManager.updateShowBadge(on)
        self.delegate?.badgeChanged()
    }
}
