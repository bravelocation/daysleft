//
//  AzureNotifications.swift
//  yeltzland
//
//  Created by John Pollard on 23/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import daysleftlibrary

open class AzureNotifications {
    #if DEBUG
    let hubName = "daysleftiospushsandbox"
    let hubListenAccess = "Endpoint=sb://daysleft.servicebus.windows.net/;SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=39vE2a/hG/a451waf3JjbmrwN/axobCh56ajdQMv0Rw="
    #else
    let hubName = "daysleftiospush"
    let hubListenAccess = "Endpoint=sb://daysleftiospush.servicebus.windows.net/;SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=0VIMBBXsJhFlzE/ZoThi0wOzWGoblXyi6tvPUfIp/Hk="
    #endif
    
    var tagNames:Set<NSObject> = []
    let defaults = UserDefaults.standard
    
    var enabled: Bool {
        get {
            return self.modelData().showBadge
        }
    }
    
    init() {
        self.tagNames = ["dataupdates" as NSObject]
    }
    
    func setupNotifications(_ forceSetup: Bool) {
        if (forceSetup || self.enabled) {
            let application = UIApplication.shared
            
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
    }
    
    func register(_ deviceToken: Data) {
        // Register with Azure Hub
        let hub = SBNotificationHub(connectionString: self.hubListenAccess, notificationHubPath: self.hubName)
        
        if (self.enabled) {
            do {
                try hub?.registerNative(withDeviceToken: deviceToken, tags: self.tagNames)
                print("Registered with \(self.hubName) hub: \(self.tagNames)")
            }
            catch {
                print("Error registering with \(self.hubName) hub")
            }
        } else {
            do {
                try hub?.unregisterAll(withDeviceToken: deviceToken)
                print("Unregistered with \(self.hubName) hub")
            }
            catch {
                print("Error unregistering with \(self.hubName) hub")
            }
        }
    }
    
    func modelData() -> DaysLeftModel {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.model
    }
}
