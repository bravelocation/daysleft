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
import OSLog

/// Class to manage registering for remote notifications via Firebase
class FirebaseNotifications: NSObject, MessagingDelegate {
    
    /// Logger
    private let logger = Logger(subsystem: "com.bravelocation.daysleft", category: "FirebaseNotifications")
    
    /// Name of the topic the notifications use
    let topicName: String = "dataupdates"
    
    /// Are notifications enabled?
    var enabled: Bool {
        return AppSettingsDataManager().appControlSettings.showBadge
    }
    
    /// Class initialiser
    override init() {
        super.init()
        
        // Must be done after FirebaseApp.configure() according to https://github.com/firebase/firebase-ios-sdk/issues/2240
        Messaging.messaging().delegate = self
    }
    
    /// Sets up notifications for the app
    /// - Parameter forceSetup: Should we force a request for authorisation?
    func setupNotifications(_ forceSetup: Bool) {
        if forceSetup || self.enabled {
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge]) { (granted, _) in
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }
    }
    
    /// Register the token
    /// - Parameter deviceToken: Device token
    func register(_ deviceToken: Data) {
        // Register with Firebase Hub
        self.logger.debug("Remote device token received")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // MARK: - MessagingDelegate implementation
    
    /// Delegate function for when a message token is received
    /// - Parameters:
    ///   - messaging: Messaging reference
    ///   - fcmToken: Token received
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        self.logger.debug("Firebase registration token: \(String(describing: fcmToken))")
        
        if self.enabled {
            Messaging.messaging().subscribe(toTopic: self.topicName)
            self.logger.debug("Registered with Firebase: \(self.topicName)")
        } else {
            Messaging.messaging().unsubscribe(fromTopic: self.topicName)
            self.logger.debug("Unregistered with firebase \(self.topicName)")
        }
    }
}
