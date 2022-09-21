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

class MainViewHostingController<Content: View>: UIHostingController<Content>, ViewModelActionDelegate {

    let dataManager = AppSettingsDataManager()
    let viewModel: DaysLeftViewModel
    var dayChangeTimer: Timer?
    
    /// Subscribers to change events
    private var cancellables = Array<AnyCancellable>()

    init() {
        self.viewModel = DaysLeftViewModel(dataManager: self.dataManager)
        
        let secondsInADay: Double = 24*60*60
        
        let rootView = MainView(model: self.viewModel)
        super.init(rootView: AnyView(rootView) as! Content)
        
        self.viewModel.delegate = self
        
        // Setup timer to update on a day change
        self.dayChangeTimer = Timer(fireAt: Date().addingTimeInterval(secondsInADay).startOfDay,
                                    interval: secondsInADay,
                                    target: self,
                                    selector: #selector(MainViewHostingController.dayChangedTimerFired), userInfo: nil, repeats: false)

    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Event handlers
    @objc
    func dayChangedTimerFired(_ timer: Timer) {
        self.viewModel.updateViewData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        
        // Setup user intents
        self.setupHandoff()
        self.donateInteraction()
        
        // Setup menu command handler
        self.setupMenuCommandHandler()
    }
    
    func share() {
        let modelText = self.dataManager.appSettings.fullDescription(Date())
        let objectsToShare = [modelText]
        
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.popoverPresentationController?.sourceRect = .zero
                
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func edit() {
        let settingsViewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "SettingsViewController")
        self.navigationController?.pushViewController(settingsViewController, animated: true)
    }
    
    // MARK: - User Activity functions
    private func donateInteraction() {
        let intent = DaysLeftIntent()
        intent.suggestedInvocationPhrase = "How Many Days Left"
                    
        // Donate relevant daily shortcut
        var relevantShortcuts: [INRelevantShortcut] = []
        
        if let shortcut = INShortcut(intent: intent) {
            
            let relevantShortcut = INRelevantShortcut(shortcut: shortcut)
            relevantShortcut.shortcutRole = INRelevantShortcutRole.action
            
            let dailyProvider = INDailyRoutineRelevanceProvider(situation: .morning)
            relevantShortcut.relevanceProviders = [dailyProvider]
            
            // Set template for displaying on Watch face
            let appSettings = self.dataManager.appSettings
            let templateTitle = appSettings.weekdaysOnly ? "Weekdays until" : "Days until"
            let templateSubTitle = appSettings.title

            let template = INDefaultCardTemplate(title: templateTitle)
            template.subtitle = templateSubTitle
            relevantShortcut.watchTemplate = template
            
            relevantShortcuts.append(relevantShortcut)
        }
        
        INRelevantShortcutStore.default.setRelevantShortcuts(relevantShortcuts) { (error) in
            if let error = error {
                print("Failed to set relevant shortcuts. \(error))")
            } else {
                print("Relevant shortcuts set.")
            }
        }
    }

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

