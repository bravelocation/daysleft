//
//  WatchConnectivityManager.swift
//  DaysLeft
//
//  Created by John Pollard on 27/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Foundation
import WatchConnectivity
import WidgetKit

#if canImport(WatchKit)
import WatchKit
import ClockKit
#endif

class WatchConnectivityManager: NSObject, WCSessionDelegate {
    
    public enum AnalyticsValues: String {
        case eventName = "event_name"
        case systemName = "system_name"
        case systemVersion = "system_version"
        case currentDay = "current_day"
    }

    static let shared = WatchConnectivityManager()
    
    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            WCSession.default.delegate = self
        }
    }
    
    public func setupConnection() {
        if WCSession.isSupported() {
            WCSession.default.activate()
        }
    }
    
    #if os(watchOS)
    public func sendConnectionMessage(eventName: String) {
        
        // Check we are connected and the companion app is installed
        guard WCSession.default.activationState == .activated else {
            return
        }
        
        guard WCSession.default.isCompanionAppInstalled else {
            return
        }
        
        var deviceDetails: [String: Any] = [:]
        deviceDetails[AnalyticsValues.eventName.rawValue] = eventName
        deviceDetails[AnalyticsValues.systemName.rawValue] = WKInterfaceDevice.current().systemName
        deviceDetails[AnalyticsValues.systemVersion.rawValue] = WKInterfaceDevice.current().systemVersion
        
        // Context is only sent if the values have changed since last call, so add in a date parameter so sent only once per day
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        deviceDetails[AnalyticsValues.currentDay.rawValue] = formatter.string(from: Date())

        do {
            try WCSession.default.updateApplicationContext(deviceDetails)
        } catch {
            print("A problem occurred sending the analytics details from the watch")
        }
    }
    #endif
    
    // MARK: - Complication update messages
    #if os(iOS)
    public func sendComplicationUpdateMessage() {
        if (WCSession.isSupported() && WCSession.default.isComplicationEnabled) {
            let userInfo = ["updateComplications": true]
            _ = WCSession.default.transferCurrentComplicationUserInfo(userInfo)
        }
    }
    #endif
    
    #if os(watchOS)
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        // If we receive an update message, update the complications
        print("Updating complications due to receiving userInfo...")
        let complicationServer = CLKComplicationServer.sharedInstance()
        
        if let activeComplications = complicationServer.activeComplications {
            for complication in activeComplications {
                complicationServer.reloadTimeline(for: complication)
            }
        }
        
        // Should we be updating widgets too?
        WidgetCenter.shared.reloadAllTimelines()
        
        print("Complications updated")
    }
    #endif
    
    // MARK: - WCSessionDelegate implementation
    @objc
    public func session(_ session: WCSession,
                        activationDidCompleteWith activationState: WCSessionActivationState,
                        error: Error?) {
        #if os(watchOS)
        WatchConnectivityManager.shared.sendConnectionMessage(eventName: "session_activated")
        #endif
    }
  
#if os(iOS)
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        AnalyticsManager.shared.logWatchEvent(messageParameters: applicationContext)
    }
    
    @objc
    public func sessionDidBecomeInactive(_ session: WCSession) {}
    
    @objc
    public func sessionDidDeactivate(_ session: WCSession) {}
#endif
}
