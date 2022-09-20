//
//  FirebaseNotifications.swift
//  daysleft
//
//  Created by John Pollard on 25/11/2017.
//  Copyright © 2017 Brave Location Software. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging

class FirebaseNotifications: NSObject, MessagingDelegate {

    var topicName: String? = nil
    
    let defaults = UserDefaults.standard
    
    var enabled: Bool {
        get {
            return self.modelData().appControlSettings.showBadge
        }
    }
    
    override init() {
        super.init()
        
        self.topicName = "dataupdates"

        // Must be done after FirebaseApp.configure() according to https://github.com/firebase/firebase-ios-sdk/issues/2240
        Messaging.messaging().delegate = self
    }
    
    func setupNotifications(_ forceSetup: Bool) {
        if (forceSetup || self.enabled) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge]) { (granted, _) in
                if (granted) {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }
    }
    
    func register(_ deviceToken: Data) {
        // Register with Firebase Hub
        print("Remote device token received")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // MARK: - MessagingDelegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        if let fullTopic = self.topicName {
            if self.enabled {
                Messaging.messaging().subscribe(toTopic: fullTopic)
                print("Registered with Firebase: \(fullTopic)")
            } else {
                Messaging.messaging().unsubscribe(fromTopic: fullTopic)
                print("Unregistered with firebase \(fullTopic)")
            }
        }
    }
    
    func modelData() -> AppSettingsDataManager {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.model
    }
}
