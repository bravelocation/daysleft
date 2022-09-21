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

/// Main view hosting controller
class SettingsViewHostingController<Content: View>: UIHostingController<Content> {
    
    /// Data manager
    let dataManager = AppSettingsDataManager()
    
    /// View model for view
    let viewModel: SettingsViewModel
    
    /// Initialiser
    init() {
        self.viewModel = SettingsViewModel(dataManager: self.dataManager)
        
        let rootView = SettingsView(model: self.viewModel)
        super.init(rootView: AnyView(rootView) as! Content)
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
}
