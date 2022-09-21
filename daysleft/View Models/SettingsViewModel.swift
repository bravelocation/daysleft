//
//  SettingsViewModel.swift
//  DaysLeft
//
//  Created by John Pollard on 21/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Foundation
import Combine
import UIKit

protocol SettingsActionDelegate {
    func badgeChanged()
    func becomeASupporter()
}

/// Settings view model
class SettingsViewModel: ObservableObject {
    /// Current app settings
    private(set) var appSettings: AppSettings
    
    /// Current app control settings
    private(set) var appControlSettings: AppControlSettings

    /// Delegate for view actions
    var delegate: SettingsActionDelegate? = nil
    
    /// Data manager
    private let dataManager: AppSettingsDataManager
    
    var versionNumber: String {
        let infoDictionary = Bundle.main
        let version = infoDictionary.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build = infoDictionary.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        return "v\(version).\(build)"
    }
    
    /// Initialiser
    /// - Parameter dataManager: Data manager
    init(dataManager: AppSettingsDataManager) {
        self.dataManager = dataManager
        self.appSettings = self.dataManager.appSettings
        self.appControlSettings = self.dataManager.appControlSettings
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
    
    /// Open external URL
    /// - Parameter value: URL to pen as a string
    func openExternalUrl(_ value: String) {
        if let url = URL(string: value) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    /// Open become a supporter view controller
    func becomeASupporter() {
        self.delegate?.becomeASupporter()
    }
}
