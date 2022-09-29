//
//  MainViewHostingController.swift
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
class MainViewHostingController<Content: View>: UIHostingController<Content>, ViewModelActionDelegate {
    
    /// Data manager
    private var dataManager: AppSettingsDataManager
    
    /// View model for view
    private let viewModel: DaysLeftViewModel
    
    /// Timer that runs at the start of each day
    private var dayChangeTimer: Timer?
    
    /// Subscribers to change events
    private var cancellables = Array<AnyCancellable>()
    
    /// Initialiser
    init() {
        self.dataManager = AppSettingsDataManager()
        
        // If running UI tests or in the simulator, use the InMemoryDataProvider
        #if DEBUG
        if CommandLine.arguments.contains("-enable-ui-testing") || UIDevice.isSimulator {
            self.dataManager = AppSettingsDataManager(dataProvider: InMemoryDataProvider.shared)
        }
        #endif
        
        self.viewModel = DaysLeftViewModel(dataManager: self.dataManager)
        
        let secondsInADay: Double = 24*60*60
        
        let rootView = MainView(model: self.viewModel)
        super.init(rootView: AnyView(rootView) as! Content)
        
        self.viewModel.delegate = self
        
        // Setup timer to update at
        self.dayChangeTimer = Timer(fireAt: Date().addingTimeInterval(secondsInADay).startOfDay,
                                    interval: secondsInADay,
                                    target: self,
                                    selector: #selector(MainViewHostingController.dayChangedTimerFired),
                                    userInfo: nil,
                                    repeats: true)

    }
    
    /// Required initialiser for view controllers - should not be used
    /// - Parameter aDecoder: Coder
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Event handlers
    
    /// Event handler if the day changed timer fires
    /// - Parameter timer: Timer that fired
    @objc func dayChangedTimerFired(_ timer: Timer) {
        self.viewModel.updateViewData()
    }
    
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
        
        // Setup handoff
        self.setupHandoff()
        
        // Setup menu command handler
        self.setupMenuCommandHandler()
    }
    
    /// Event handler for when view appears
    /// - Parameter animated: Animated or not
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AnalyticsManager.shared.logScreenView(screenName: "Main Screen")
    }
    
    // MARK: - ViewModelActionDelegate
    
    /// Called to share the current model
    func share() {
        let modelText = self.dataManager.appSettings.fullDescription(Date())
        let objectsToShare = [modelText]
        
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.popoverPresentationController?.sourceRect = .zero
                
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    /// Called to load the settings screen
    func edit() {
        let settingsViewController = SettingsViewHostingController<AnyView>()
        self.navigationController?.pushViewController(settingsViewController, animated: true)
    }

    // MARK: - User Activity functions
    /// Sets up handoff
    @objc func setupHandoff() {
        // Set activity for handoff
        let activity = NSUserActivity(activityType: "com.bravelocation.daysleft.mainscreen")
        
        // Eligible for handoff
        activity.isEligibleForHandoff = true
        activity.isEligibleForSearch = true
        activity.title = "Days Left"
        activity.needsSave = true
        
        self.userActivity = activity
        self.userActivity?.becomeCurrent()
    }
}

// MARK: - Menu options

extension MainViewHostingController {
    /// Sets up handlers for any meu commands
    func setupMenuCommandHandler() {
        let editSubscriber = NotificationCenter.default.publisher(for: .editCommand)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { _ in
                self.edit()
            })
        self.cancellables.append(editSubscriber)
        
        let shareSubscriber = NotificationCenter.default.publisher(for: .shareCommand)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { _ in
                self.share()
            })
        
        self.cancellables.append(shareSubscriber)
    }
}
