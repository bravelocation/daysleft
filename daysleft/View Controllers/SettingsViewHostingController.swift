//
//  SettingsViewHostingController.swift
//  DaysLeft
//
//  Created by John Pollard on 21/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Combine
import Foundation
import Intents
import SwiftUI
import WidgetKit

/// Main view hosting controller
class SettingsViewHostingController<Content: View>: UIHostingController<Content>, SettingsActionDelegate {

    /// Data manager
    private var dataManager: AppSettingsDataManager
    
    /// View model for view
    private let viewModel: SettingsViewModel
    
    /// Initialiser
    init() {
        self.dataManager = AppSettingsDataManager()
        
        // If running UI tests or in the simulator, use the InMemoryDataProvider
        #if DEBUG
        if CommandLine.arguments.contains("-enable-ui-testing") || UIDevice.isSimulator {
            self.dataManager = AppSettingsDataManager(dataProvider: InMemoryDataProvider.shared)
        }
        #endif
        
        self.viewModel = SettingsViewModel(dataManager: self.dataManager)
        let appSettings = self.dataManager.appSettings
        
        let rootView = SettingsView(model: self.viewModel,
                                    start: appSettings.start,
                                    end: appSettings.end,
                                    title: appSettings.title,
                                    weekdaysOnly: appSettings.weekdaysOnly,
                                    showBadge: dataManager.appControlSettings.showBadge)
        
        // swiftlint:disable:next force_cast
        super.init(rootView: rootView as! Content)
        
        self.viewModel.delegate = self
    }
    
    /// Required initialiser for view controllers - should not be used
    /// - Parameter aDecoder: Coder
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Event handlers
    
    /// Event handler for view loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customise the nav bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "MainAppColor")
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = self.navigationController?.navigationBar.standardAppearance
        
        let buttonAppearance = UIBarButtonItemAppearance(style: .plain)
        buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.buttonAppearance = buttonAppearance
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    /// Event handler for when view appears
    /// - Parameter animated: Animated or not
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AnalyticsManager.shared.logScreenView(screenName: "Settings Screen")
    }
    
    // MARK: - SettingsActionDelegate
    /// Event handler for when badge toggle changes
    func badgeChanged() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.registerForNotifications()
        }
    }
    
    /// Event handler for when data changes
    func dataUpdated() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.updateExternalInformation()
        }
    }
}
