//
//  AppDelegate.swift
//  daysleft
//
//  Created by John Pollard on 11/02/2015.
//  Copyright (c) 2015 Brave Location Software. All rights reserved.
//

@preconcurrency import UIKit
import Firebase
import WidgetKit
import Combine
import OSLog
import BackgroundTasks
import TipKit

/// Application delegate for the app
@MainActor
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    /// Logger
    private let logger = Logger(subsystem: "com.bravelocation.daysleft.v2", category: "AppDelegate")

    // MARK: Class properties
    
    /// Main app window
    var window: UIWindow?
    
    /// Manager for Firebase notifications
    var firebaseNotifications: FirebaseNotifications?
    
    /// Subscribers to change events
    private var cancellables = [AnyCancellable]()
    
    /// App data manager
    let dataManager = AppSettingsDataManager()
    
    /// Watch connectivity manager
    let watchConnectivityManager = WatchConnectivityManager()

    // MARK: Initialisation
    
    /// Initialiser
    override init() {
        super.init()
        
        // Set nav bar for all views
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "MainAppColor")
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Setup listener for iCloud setting change
        Task {
            await MainActor.run {
                let keyValueChangeSubscriber = NotificationCenter.default
                    .publisher(for: .AppSettingsUpdated)
                    .sink { _ in
                        self.iCloudSettingsUpdated()
                    }
                
                self.cancellables.append(keyValueChangeSubscriber)
            }
        }
        
        // Setup TipKit
        try? Tips.configure([
            .displayFrequency(.daily)
        ])
    }
    
    // MARK: Update external information function
    
    /// Updates all external information e.g. badges, widgets, watch settings
    func updateExternalInformation() {
        // Update the app badge if required
        self.updateBadge()
        
        // Reload any widgets
        WidgetCenter.shared.reloadAllTimelines()
        
        if #available(iOS 18.0, *) {
            ControlCenter.shared.reloadAllControls()
            self.logger.debug("Updated control center widgets")
        }
        
        // Tell the watch to update it's complications
        self.watchConnectivityManager.sendComplicationUpdateMessage()
    }
    
    // MARK: UIApplicationDelegate functions
    
    /// Delegate called after app finished launching
    /// - Parameters:
    ///   - application: Current application
    ///   - launchOptions: Launch options
    /// - Returns: True if can launch app successfully
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        // Must be done after FirebaseApp.configure() according to https://github.com/firebase/firebase-ios-sdk/issues/2240
        self.firebaseNotifications = FirebaseNotifications()
        
        // Setup watch session
        self.watchConnectivityManager.setupConnection()

        // Setup push notifications (if required) to ensure the badge gets updated
        UNUserNotificationCenter.current().delegate = self
        self.firebaseNotifications?.setupNotifications(false)
        
        // Update any external info on app start
        self.updateExternalInformation()
        
        // Schedule a background refresh to update the badge, and schedule the first one
        self.initBackgroundBadgeUpdate()
        self.scheduleAppRefresh()

        return true
    }
    
    /// Delegate method when an app has successfully registered for remote notifications
    /// - Parameters:
    ///   - application: Current application
    ///   - deviceToken: Device token returned
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.firebaseNotifications?.register(deviceToken)
    }
    
    /// Delegate method called when registering for remote notifications failed
    /// - Parameters:
    ///   - application: Current application
    ///   - error: Error description
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        self.logger.debug("Device token for push notifications: FAIL -- ")
        self.logger.debug("\(error.localizedDescription)")
    }
    
    /// Delegate method called when restoring a user activity i.e via handoff
    /// - Parameters:
    ///   - application: Current application
    ///   - userActivity: User activity to restore
    ///   - restorationHandler: Restoration handler
    /// - Returns: True if has handled restoration
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let window = self.window {
            window.rootViewController?.restoreUserActivityState(userActivity)
        }
        
        return true
    }
    
    /// Delegate called if the app receives a remote notification
    /// - Parameters:
    ///   - application: Current application
    ///   - userInfo: User info sent
    ///   - completionHandler: Completion handler to be called when complete
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)
                       -> Void) {
        self.logger.debug("Received remote notification ...")
        Messaging.messaging().appDidReceiveMessage(userInfo)

        self.updateExternalInformation()

        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    // MARK: UISceneSession Lifecycle
    
    /// Handles configuring a scene
    /// - Parameters:
    ///   - application: Current applucation
    ///   - connectingSceneSession: Description of the scene
    ///   - options: Scene options
    /// - Returns: Scene configuration
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    // MARK: - Event handlers
    /// Event handler when iCloud change notifications are received
    @objc fileprivate func iCloudSettingsUpdated() {
        self.logger.debug("Received iCloudSettingsUpdated notification")
        
        self.updateExternalInformation()
    }
}

// MARK: - User notifications
extension AppDelegate: @preconcurrency UNUserNotificationCenterDelegate {
    /// Event handler called when a notification is received
    /// - Parameters:
    ///   - center: Notification center
    ///   - response: Message response
    ///   - completionHandler: Completion handler called once message has been dealt with
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Print message
        self.logger.debug("Notification received ...")
        
        Messaging.messaging().appDidReceiveMessage(response.notification.request.content.userInfo)
        
        self.updateExternalInformation()
        
        completionHandler()
    }
    
    /// Register for notifications and badge updates
    func registerForNotifications() {
        self.logger.debug("Registering notification settings")
        self.firebaseNotifications?.setupNotifications(true)
        self.updateBadge()
    }
    
    // MARK: - Badge functions
    
    /// Update the badge number if required
    func updateBadge() {
        if self.dataManager.appControlSettings.showBadge == false {
            clearBadge()
            return
        }
        
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            if settings.badgeSetting == .enabled {
                DispatchQueue.main.async {
                    let now: Date = Date()
                    
                    UNUserNotificationCenter.current().setBadgeCount(self.dataManager.appSettings.daysLeft(now))
                    self.logger.debug("Updated app badge to \(self.dataManager.appSettings.daysLeft(now))")
                }
            }
        }
    }
    
    /// Clear the badge number if required
    func clearBadge() {
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            if settings.badgeSetting == .enabled {
                DispatchQueue.main.async {
                    UNUserNotificationCenter.current().setBadgeCount(0)
                    self.logger.debug("Updated app badge to 0")
                }
            }
        }
    
    }
}

// MARK: - Background refresh
extension AppDelegate {
    func initBackgroundBadgeUpdate() {
        // Schedule a background refresh to update the badge
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.bravelocation.daysleft.v2.background-badge-update", using: .main) { task in
            if let task = task as? BGAppRefreshTask {
                self.handleAppRefresh(task: task)
            }
        }
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.bravelocation.daysleft.v2.background-badge-update")
        
        // Fetch no earlier than a minute after start of day tomorrow
        let startOfDayTomorrow = Date.now.startOfDay.addDays(1)
        let justAfterMidnightTomorrow = Calendar.current.date(byAdding: .minute, value: 1, to: startOfDayTomorrow)!
        request.earliestBeginDate = justAfterMidnightTomorrow
        
        self.logger.debug("Scheduling background refresh for \(justAfterMidnightTomorrow)")
            
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            self.logger.error("Could not schedule app refresh: \(error)")
        }
    }
    
    func handleAppRefresh(task: BGAppRefreshTask) {
        // Schedule a new refresh task.
        self.scheduleAppRefresh()
        
        // Update the badge
        self.updateBadge()

        // set the background task as completed
        task.setTaskCompleted(success: true)
    }
}
