//
//  Notification+Name.swift
//  DaysLeft
//
//  Created by John Pollard on 29/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(WatchKit)
import WatchKit
#endif

extension Notification.Name {
    static var WillEnterForegroundNotification: Notification.Name {
        get {
            #if os(iOS)
                return UIApplication.willEnterForegroundNotification
            #endif
            #if os(watchOS)
                return WKExtension.applicationWillEnterForegroundNotification
            #endif
        }
    }
    
    /// Name of the notification sent when app settings are updated
    static let AppSettingsUpdated = Notification.Name(rawValue: "UpdateSettingsNotification")
}
