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

open class FirebaseNotifications: NSObject, MessagingDelegate {

    var topicName:String? = nil
    
    let defaults = UserDefaults.standard
    
    var enabled: Bool {
        get {
            return self.modelData().showBadge
        }
    }
    
    override init() {
        super.init()
        
        self.topicName = "dataupdates"
        Messaging.messaging().delegate = self
    }
    
    func setupNotifications(_ forceSetup: Bool) {
        if (forceSetup || self.enabled) {
            let application = UIApplication.shared
            
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
    }
    
    func register(_ deviceToken: Data) {
        // Register with Firebase Hub
        Messaging.messaging().apnsToken = deviceToken
        
        let fullTopic = "/topics/" + self.topicName!
        
        if (self.enabled) {
            Messaging.messaging().subscribe(toTopic: fullTopic)
            print("Registered with Firebase: \(fullTopic)")
        } else {
            Messaging.messaging().unsubscribe(fromTopic: fullTopic)
            print("Unregistered with firebase \(fullTopic)")
        }
    }
    
    // MARK: - MessagingDelegate
    public func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
    }
    
    func modelData() -> AppDaysLeftModel {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.model
    }
}
