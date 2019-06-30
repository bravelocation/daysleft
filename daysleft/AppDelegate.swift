//
//  AppDelegate.swift
//  daysleft
//
//  Created by John Pollard on 11/02/2015.
//  Copyright (c) 2015 Brave Location Software. All rights reserved.
//

import UIKit
import daysleftlibrary
import GoogleMobileAds
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var model = AppDaysLeftModel()
    let firebaseNotifications = FirebaseNotifications()

    override init() {
        super.init()
        
        // Setup listener for iCloud setting change
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.iCloudSettingsUpdated(_:)), name: NSNotification.Name(rawValue: AppDaysLeftModel.iCloudSettingsNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        print("Configured Google Ads")
        
        // Setup push notifications (if required) to ensure the badge gets updated
        UNUserNotificationCenter.current().delegate = self
        self.firebaseNotifications.setupNotifications(false)

        // Increment the number of times app opened
        self.model.appOpenCount = self.model.appOpenCount + 1;

        return true
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.firebaseNotifications.register(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Device token for push notifications: FAIL -- ")
        print(error.localizedDescription)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if let window = self.window {
            window.rootViewController?.restoreUserActivityState(userActivity)
        }
        
        return true
    }
    
    @objc
    fileprivate func iCloudSettingsUpdated(_ notification: Notification) {
        print("Received iCloudSettingsUpdated notification")
        
        // Push latest settings and update badge
        self.model.pushAllSettingsToWatch()
        self.updateBadge()
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Print message
        print("Notification received ...")
        
        Messaging.messaging().appDidReceiveMessage(response.notification.request.content.userInfo)
        
        // Push latest settings and update badge
        self.model.pushAllSettingsToWatch()
        self.updateBadge()
        
        completionHandler()
    }
    
    func registerForNotifications() {
        print("Registering notification settings")
        self.firebaseNotifications.setupNotifications(true)
        self.updateBadge()
    }
    
    func updateBadge() {
        if (self.model.showBadge == false) {
            clearBadge()
            return
        }
        
        UNUserNotificationCenter.current().getNotificationSettings() {settings in
            if settings.badgeSetting == .enabled {
                DispatchQueue.main.async {
                    let now: Date = Date()
                    UIApplication.shared.applicationIconBadgeNumber = self.model.DaysLeft(now)
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
}
