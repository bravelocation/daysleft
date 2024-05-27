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
import OSLog

#if canImport(WatchKit)
import WatchKit
import ClockKit
#endif

/// Class that manages interactions between the watch and the main app
class WatchConnectivityManager: NSObject, WCSessionDelegate {
    
    /// Logger
    private let logger = Logger(subsystem: "com.bravelocation.daysleft.v2", category: "WatchConnectivityManager")
    
    /// Analytics values that will be returned from the watch on connection
    public enum AnalyticsValues: String {
        case eventName = "event_name"
        case systemName = "system_name"
        case systemVersion = "system_version"
        case currentDay = "current_day"
    }
    
    /// Initialiser
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            WCSession.default.delegate = self
        }
    }
    
    /// Attempts to setup a connection between the app and the watch
    public func setupConnection() {
        if WCSession.isSupported() {
            WCSession.default.activate()
        }
    }
    
    // MARK: - Complication update messages
    
    #if os(iOS)
    /// Sends a message to the watch to update the complications
    public func sendComplicationUpdateMessage() {
        if WCSession.isSupported() && WCSession.default.isComplicationEnabled {
            let userInfo = ["updateComplications": true]
            _ = WCSession.default.transferCurrentComplicationUserInfo(userInfo)
        }
    }
    #endif
    
    // MARK: - WCSessionDelegate implementation

    // MARK: watchOS only functions
    
    #if os(watchOS)
    /// Delegate method called on the watch when it receives user information e.g. when complications should be updated because of a data change detected
    /// - Parameters:
    ///   - session: Current session
    ///   - userInfo: User info sent in the message
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        // If we receive an update message, update the complications
        self.logger.debug("Updating complications due to receiving userInfo...")
        let complicationServer = CLKComplicationServer.sharedInstance()
        
        if let activeComplications = complicationServer.activeComplications {
            for complication in activeComplications {
                complicationServer.reloadTimeline(for: complication)
            }
        }
        
        // Should we be updating widgets too?
        WidgetCenter.shared.reloadAllTimelines()
        
        self.logger.debug("Complications updated")
    }
    #endif
    
    /// Delegate method called when a session has been activated
    /// - Parameters:
    ///   - session: Session details
    ///   - activationState: Activation state
    ///   - error: Error
    @objc
    public func session(_ session: WCSession,
                        activationDidCompleteWith activationState: WCSessionActivationState,
                        error: Error?) {
        // If we are on the watch, send a connection message to the phone with analytics details
    #if os(watchOS)
        // Check we are connected and the companion app is installed
        guard WCSession.default.activationState == .activated else {
            return
        }
        
        guard WCSession.default.isCompanionAppInstalled else {
            return
        }
        
        var deviceDetails: [String: Any] = [:]
        deviceDetails[AnalyticsValues.eventName.rawValue] = "session_activated"
        deviceDetails[AnalyticsValues.systemName.rawValue] = WKInterfaceDevice.current().systemName
        deviceDetails[AnalyticsValues.systemVersion.rawValue] = WKInterfaceDevice.current().systemVersion
        
        // Context is only sent if the values have changed since last call, so add in a date parameter so sent only once per day
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        deviceDetails[AnalyticsValues.currentDay.rawValue] = formatter.string(from: Date())

        do {
            try WCSession.default.updateApplicationContext(deviceDetails)
        } catch {
            self.logger.debug("A problem occurred sending the analytics details from the watch")
        }
        
    #endif
    }
    
// MARK: iOS only functions
  
#if os(iOS)
    /// On phone, delegate method called when application context information is received
    /// - Parameters:
    ///   - session: Session
    ///   - applicationContext: Context data received
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        AnalyticsManager.shared.logWatchEvent(messageParameters: applicationContext)
    }
    
    /// Placeholder delegate method when session becomes inactive
    /// - Parameter session: Session
    @objc public func sessionDidBecomeInactive(_ session: WCSession) {
        // Nothing to do
    }
    
    /// Placeholder delegate method when session becomes deactivated
    /// - Parameter session: Session
    @objc public func sessionDidDeactivate(_ session: WCSession) {
        // Nothing to do
    }
#endif
    
}
