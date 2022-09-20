//
//  AppDelegate.swift
//  daysleft
//
//  Created by John Pollard on 11/02/2015.
//  Copyright (c) 2015 Brave Location Software. All rights reserved.
//

import UIKit
import Firebase
import WidgetKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: Class properties
    var window: UIWindow?
    lazy var model = AppDaysLeftModel()
    var firebaseNotifications: FirebaseNotifications?

    // MARK: Initialisation
    override init() {
        super.init()
        
        // Setup listener for iCloud setting change
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.iCloudSettingsUpdated(_:)), name: NSNotification.Name(rawValue: AppDaysLeftModel.iCloudSettingsNotification), object: nil)
    }
    
    // MARK: UIApplicationDelegate functions
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        // Must be done after FirebaseApp.configure() according to https://github.com/firebase/firebase-ios-sdk/issues/2240
        self.firebaseNotifications = FirebaseNotifications()

        // Setup push notifications (if required) to ensure the badge gets updated
        UNUserNotificationCenter.current().delegate = self
        self.firebaseNotifications?.setupNotifications(false)

        // Increment the number of times app opened
        self.model.appControlSettings = AppControlSettings(firstRun: self.model.appControlSettings.firstRun,
                                                           showBadge: self.model.appControlSettings.showBadge,
                                                           isASupporter: self.model.appControlSettings.isASupporter,
                                                           appOpenCount: self.model.appControlSettings.appOpenCount + 1)

        return true
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.firebaseNotifications?.register(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Device token for push notifications: FAIL -- ")
        print(error.localizedDescription)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let window = self.window {
            window.rootViewController?.restoreUserActivityState(userActivity)
        }
        
        return true
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)
                       -> Void) {
        Messaging.messaging().appDidReceiveMessage(userInfo)

        // Push latest settings and update badge
        self.updateBadge()
        self.model.pushAllSettingsToWatch()

        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: Event handlers
    @objc
    fileprivate func iCloudSettingsUpdated(_ notification: Notification) {
        print("Received iCloudSettingsUpdated notification")
        
        // Push latest settings and update badge
        self.updateBadge()
        self.model.pushAllSettingsToWatch()
    }
}

// MARK: - User notifications
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Print message
        print("Notification received ...")
        
        Messaging.messaging().appDidReceiveMessage(response.notification.request.content.userInfo)
        
        // Push latest settings and update badge
        self.updateBadge()
        self.model.pushAllSettingsToWatch()
        
        completionHandler()
    }
    
    func registerForNotifications() {
        print("Registering notification settings")
        self.firebaseNotifications?.setupNotifications(true)
        self.updateBadge()
    }
    
    // MARK: Badge functions
    func updateBadge() {
        if (self.model.appControlSettings.showBadge == false) {
            clearBadge()
            return
        }
        
        UNUserNotificationCenter.current().getNotificationSettings() {settings in
            if settings.badgeSetting == .enabled {
                DispatchQueue.main.async {
                    let now: Date = Date()
                    UIApplication.shared.applicationIconBadgeNumber = self.model.appSettings.daysLeft(now)
                    print("Updated app badge")
                }
            }
        }
    }
    
    func clearBadge() {
        UNUserNotificationCenter.current().getNotificationSettings() {settings in
            if settings.badgeSetting == .enabled {
                DispatchQueue.main.async {
                    UIApplication.shared.applicationIconBadgeNumber = 0
                    print("Cleared app badge")
                }
            }
        }
    }
    
    // MARK: Widget functions
    func updateWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
