//
//  ViewController.swift
//  daysleft
//
//  Created by John Pollard on 11/02/2015.
//  Copyright (c) 2015 Brave Location Software. All rights reserved.
//

import UIKit
import StoreKit
import Intents
import Combine

class ViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var labelDaysLeft: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var counterView: CounterView!
    @IBOutlet weak var labelStartDate: UILabel!
    @IBOutlet weak var labelEndDate: UILabel!
    @IBOutlet weak var labelPercentageDone: UILabel!
    @IBOutlet weak var counterWidth: NSLayoutConstraint!
    
    var dayChangeTimer: Timer!
    var shareButton: UIBarButtonItem!
    var editButton: UIBarButtonItem!
    
    private lazy var editSubscriber: AnyCancellable? = nil
    
    private lazy var shareSubscriber: AnyCancellable? = nil

    // MARK: - Initialisation
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.setupNotificationHandlers()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setupNotificationHandlers()
    }
    
    func setupNotificationHandlers() {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.iCloudSettingsUpdated(_:)), name: NSNotification.Name(rawValue: AppDaysLeftModel.iCloudSettingsNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.appEntersForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    // MARK: - View event handlers
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Customise the nav bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "MainAppColor")
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = self.navigationController?.navigationBar.standardAppearance

        // Add a nav bar buttons
        self.shareButton = UIBarButtonItem.init(barButtonSystemItem: .action, target: self, action: #selector(ViewController.shareButtonTouchUp))
        self.editButton = UIBarButtonItem.init(barButtonSystemItem: .edit, target: self, action: #selector(ViewController.editButtonTouchUp))
        
        self.navigationItem.leftBarButtonItems = [shareButton]
        self.navigationItem.rightBarButtonItems = [editButton]
        
        // Add a swipe recogniser
        let swipeLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.swipeLeft(_:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)
        
        // Add timer in case runs over a day change
        let now = Date()
        let secondsInADay: Double = 60 * 60 * 24
        let startOfTomorrow = now.startOfDay.addDays(1)
        self.dayChangeTimer = Timer(fireAt: startOfTomorrow, interval: secondsInADay, target: self, selector: #selector(ViewController.dayChangedTimerFired), userInfo: nil, repeats: false)
        
        // Setup user intents
        self.setupHandoff()
        self.donateInteraction()
        
        // Setup menu command handler
        self.setupMenuCommandHandler()
    }
 
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.counterView.clearControl()
        self.updateViewFromModel()
        
        // Show request review every 10 times the user opend the app
        let reviewPromptFrequency = 10
        
        let appOpened = self.modelData().appOpenCount
        print("App opened \(appOpened) times")

        if (appOpened >= reviewPromptFrequency && (appOpened % reviewPromptFrequency) == 0) {
            SKStoreReviewController.requestReview()
        }
        
        AnalyticsManager.shared.logScreenView(screenName: "Main Screen")
    }
    
    // MARK: - Handle rotations
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: nil, completion: { _ in self.counterView.updateControl() })
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if (previousTraitCollection == nil) {
            // Initialisation, so no need to update
            return
        }
        
        if (self.traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass || self.traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass) {
            self.counterView.updateControl()
        }
    }
    
    // MARK: - Event handlers
    @objc
    func dayChangedTimerFired(_ timer: Timer) {
        self.updateViewFromModel()
    }
    
    @objc
    func swipeLeft(_ gesture: UISwipeGestureRecognizer) {
        self.performSegue(withIdentifier: "segueShowSettings", sender: self)
    }
    
    @objc
    func shareButtonTouchUp() {
        let modelText = self.modelData().appSettings.fullDescription(Date())
        let objectsToShare = [modelText]
        
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = self.shareButton
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc
    func editButtonTouchUp() {
        self.performSegue(withIdentifier: "segueShowSettings", sender: self)
    }
    
    @objc
    fileprivate func iCloudSettingsUpdated(_ notification: Notification) {
        print("Received iCloud settings update notification in main view controller")
        
        // Update view data on main thread
        DispatchQueue.main.async {
            self.updateViewFromModel()
        }
    }
    
    @objc
    fileprivate func appEntersForeground() {
        print("App enters foreground in main view controller")
        
        // Update view data on main thread
        DispatchQueue.main.async {
            self.counterView.clearControl()
            self.updateViewFromModel()
        }
    }
    
    // MARK: - Helper functions
    func updateViewFromModel() {
        print("updateViewFromModel started")
        let appSettings = self.modelData().appSettings

        let now: Date = Date()
        
        // Check we're not getting a rogue update in the background
        if self.labelDaysLeft == nil {
            return
        }

        self.labelDaysLeft.text = String(format: "%d", appSettings.daysLeft(now))
        self.labelTitle.text = appSettings.description(now)

        let shortDateFormatter = DateFormatter()
        shortDateFormatter.dateFormat = "EEE d MMM"
        
        self.labelStartDate.text = String(format: "%@", shortDateFormatter.string(from: appSettings.start))
        self.labelEndDate.text = String(format: "%@", shortDateFormatter.string(from: appSettings.end))
        
        if (appSettings.daysLength == 0) {
            self.labelPercentageDone.text = ""
        } else {
            let percentageDone: Float = (Float(appSettings.daysGone(now)) * 100.0) / Float(appSettings.daysLength)
            self.labelPercentageDone.text = String(format: "%3.0f%% done", percentageDone)
        }
        
        self.counterView.counter = appSettings.daysGone(now)
        self.counterView.maximumValue = appSettings.daysLength
        self.counterView.updateControl()
        
        // Update the badge and widgets too
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.updateBadge()
        appDelegate.updateWidgets()
        
        print("updateViewFromModel completed")
    }

    func modelData() -> AppDaysLeftModel {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.model
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
            let appSettings = self.modelData().appSettings
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

// MARK: - Keyboard options

extension ViewController {
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(title: "Edit Settings", action: #selector(ViewController.keyboardSelectTab), input: "E", modifierFlags: .command),
            UIKeyCommand(title: "Share", action: #selector(ViewController.keyboardSelectTab), input: "S", modifierFlags: [.command, .shift])
        ]
    }
    
    @objc func keyboardSelectTab(sender: UIKeyCommand) {
        if let input = sender.input {
            switch input {
            case "E":
                self.editButtonTouchUp()
            case "S":
                self.shareButtonTouchUp()
            default:
                break
            }
        }
    }
}

// MARK: - Menu options

extension ViewController {
    func setupMenuCommandHandler() {
        self.editSubscriber = NotificationCenter.default.publisher(for: .editCommand)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { _ in
                self.editButtonTouchUp()
            })
        
        self.shareSubscriber = NotificationCenter.default.publisher(for: .shareCommand)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { _ in
                self.shareButtonTouchUp()
            })
    }
}
