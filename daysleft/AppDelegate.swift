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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var model = DaysLeftModel()
    let azureNotifications = AzureNotifications()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Setup analytics
        Fabric.with([Crashlytics()])
        
        // Setup push notifications (if required) to ensure the badge gets updated
        self.azureNotifications.setupNotifications(false)
        
        return true
    }
    
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        self.azureNotifications.register(deviceToken)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Device token for push notifications: FAIL -- ")
        print(error.description)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        self.messageReceived(application, userInfo: userInfo)
    }
    
    func application(application: UIApplication,
                     didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
                                                  fetchCompletionHandler handler: (UIBackgroundFetchResult) -> Void) {
        self.messageReceived(application, userInfo: userInfo)
        handler(UIBackgroundFetchResult.NewData);
    }
    
    func messageReceived(application: UIApplication,
                         userInfo: [NSObject : AnyObject]) {
        // Print message
        print("Notification received: \(userInfo)")

        // Push latest settings and update badge
        self.model.updateWatchContext()
        self.updateBadge()
    }
    
    func registerForNotifications() {
        NSLog("Registering notification settings")
        self.azureNotifications.setupNotifications(true)
        self.updateBadge()
    }
    
    func updateBadge() {
        if (self.model.showBadge == false) {
            clearBadge()
            return
        }
        
        let application: UIApplication = UIApplication.sharedApplication()
        
        let badgePermission: Bool = (application.currentUserNotificationSettings()?.types.contains(UIUserNotificationType.Badge))!
        if (badgePermission)
        {
            let now: NSDate = NSDate()
            application.applicationIconBadgeNumber = self.model.DaysLeft(now)
            NSLog("Updated app badge")
        }
    }
    
    func clearBadge() {
        let application: UIApplication = UIApplication.sharedApplication()
        
        let badgePermission: Bool = (application.currentUserNotificationSettings()?.types.contains(UIUserNotificationType.Badge))!
        if (badgePermission)
        {
            application.applicationIconBadgeNumber = 0
            NSLog("Cleared app badge")
        }
    }
}

