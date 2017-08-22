//
//  AppDelegate.swift
//  daysleft
//
//  Created by John Pollard on 11/02/2015.
//  Copyright (c) 2015 Brave Location Software. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import daysleftlibrary
import GoogleMobileAds
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var model = DaysLeftModel()
    let azureNotifications = AzureNotifications()

    
    override init() {
        super.init()
        
        // Setup listener for iCloud setting change
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.iCloudSettingsUpdated(_:)), name: NSNotification.Name(rawValue: DaysLeftModel.iCloudSettingsNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        #if RELEASE
            // Setup analytics in release mode only
            Fabric.with([Crashlytics()])
        #endif
        
        // Setup push notifications (if required) to ensure the badge gets updated
        self.azureNotifications.setupNotifications(false)
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        GADMobileAds.configure(withApplicationID: "ca-app-pub-6795405439060738~5447156632")

        return true
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.azureNotifications.register(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Device token for push notifications: FAIL -- ")
        print(error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        self.messageReceived(application, userInfo: userInfo)
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                                                  fetchCompletionHandler handler: @escaping (UIBackgroundFetchResult) -> Void) {
        self.messageReceived(application, userInfo: userInfo)
        handler(UIBackgroundFetchResult.newData);
    }
    
    func messageReceived(_ application: UIApplication,
                         userInfo: [AnyHashable: Any]) {
        // Print message
        print("Notification received ...")

        // Push latest settings and update badge
        self.model.pushAllSettingsToWatch()
        self.updateBadge()
    }
    
    func registerForNotifications() {
        print("Registering notification settings")
        self.azureNotifications.setupNotifications(true)
        self.updateBadge()
    }
    
    func updateBadge() {
        if (self.model.showBadge == false) {
            clearBadge()
            return
        }
        
        let application: UIApplication = UIApplication.shared
        
        let badgePermission: Bool = (application.currentUserNotificationSettings?.types.contains(UIUserNotificationType.badge))!
        if (badgePermission)
        {
            let now: Date = Date()
            application.applicationIconBadgeNumber = self.model.DaysLeft(now)
            print("Updated app badge")
        }
    }
    
    func clearBadge() {
        let application: UIApplication = UIApplication.shared
        
        let badgePermission: Bool = (application.currentUserNotificationSettings?.types.contains(UIUserNotificationType.badge))!
        if (badgePermission)
        {
            application.applicationIconBadgeNumber = 0
            print("Cleared app badge")
        }
    }
    
    @objc
    fileprivate func iCloudSettingsUpdated(_ notification: Notification) {
        print("Received iCloudSettingsUpdated notification")
        
        // Push latest settings and update badge
        self.model.pushAllSettingsToWatch()
        self.updateBadge()
    }
}

