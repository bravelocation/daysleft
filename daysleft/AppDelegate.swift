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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics()])
        
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)

        return true
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        // Push latest settings to watch periodically
        self.model.updateWatchContext()
        NSLog("Updating watch context from background")
        
        self.updateBadge()
        completionHandler(UIBackgroundFetchResult.NewData)
    }
    
    func registerForNotifications() {
        NSLog("Registering notification settings")
        let types: UIUserNotificationType = UIUserNotificationType.Badge
        let notificationSettings:UIUserNotificationSettings = UIUserNotificationSettings.init(forTypes: types, categories:nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
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

