//
//  SettingsViewModel.swift
//  DaysLeft
//
//  Created by John Pollard on 21/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Foundation
import Combine

/// Settings view model
class SettingsViewModel: ObservableObject {
    /// Start date published property
    @Published var start: Date
    
    /// End date published property
    @Published var end: Date
    
    /// Title published property
    @Published var title: String
    
    /// Week days only published property
    @Published var weekdaysOnly: Bool
    
    /// Show badge published property
    @Published var showBadge: Bool
    
    /// Data manager
    private let dataManager: AppSettingsDataManager
    
    /// Subscribers to change events
    private var cancellables = Array<AnyCancellable>()
    
    /// Initialiser
    /// - Parameter dataManager: Data manager
    init(dataManager: AppSettingsDataManager) {
        self.dataManager = dataManager
        
        // Set initla values of properties
        let appSettings = self.dataManager.appSettings
        self.start = appSettings.start
        self.end = appSettings.end
        self.title = appSettings.title
        self.weekdaysOnly = appSettings.weekdaysOnly
        
        let appControlSettings = self.dataManager.appControlSettings
        self.showBadge = appControlSettings.showBadge
        
        self.setupPublishers()
    }
    
    /// Setup publishers listening for changes
    private func setupPublishers() {
        let startDateListener = self.$start.sink(receiveValue: { _ in
            self.updateAppSettings()
        })
        self.cancellables.append(startDateListener)
        
        let endDateListener = self.$end.sink(receiveValue: { _ in
            self.updateAppSettings()
        })
        self.cancellables.append(endDateListener)

        let titleListener = self.$title.sink(receiveValue: { _ in
            self.updateAppSettings()
        })
        self.cancellables.append(titleListener)

        let weekdaysOnlyListener = self.$weekdaysOnly.sink(receiveValue: { _ in
            self.updateAppSettings()
        })
        self.cancellables.append(weekdaysOnlyListener)

        let badgeListener = self.$weekdaysOnly.sink(receiveValue: { _ in
            self.updateBadgeSettings()
        })
        self.cancellables.append(badgeListener)
    }
    
    private func updateAppSettings() {
        self.dataManager.updateAppSettings(start: self.start, end: self.end, title: self.title, weekdaysOnly: self.weekdaysOnly)
    }
    
    private func updateBadgeSettings() {
        self.dataManager.updateShowBadge(self.showBadge)
    }
}
