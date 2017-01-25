//
//  WatchDaysLeftModel.swift
//  daysleft
//
//  Created by John Pollard on 03/10/2015.
//  Copyright © 2015 Brave Location Software. All rights reserved.
//

import Foundation
import WatchConnectivity
import ClockKit

open class WatchDaysLeftModel: DaysLeftModel
{
    public override init() {
        super.init()
        self.updateComplications()
    }
    
    /// Send updated settings to watch
    open override func initialiseiCloudSettings() {
        // Don't setup iCloud on watch!
    }
    
    /// Write settings to iCloud store
    open override func writeSettingToiCloudStore(_ value: AnyObject, key: String) {
        // Don't write settings to iCloud when on watch!
    }
    
    /// Send initial settings to watch
    open override func pushAllSettingsToWatch() {
        // Don't send settings to watch when on watch!
    }
        
    open override func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        super.session(session, didReceiveUserInfo: userInfo)
        self.updateComplications()
    }

    open override func session(_ session: WCSession, didReceiveUpdate receivedApplicationContext: [String : AnyObject]) {
        super.session(session, didReceiveUpdate: receivedApplicationContext)
        self.updateComplications()
    }
    
    func updateComplications() {
        NSLog("Updating complications...")
        let complicationServer = CLKComplicationServer.sharedInstance()
        let activeComplications = complicationServer.activeComplications
        
        if (activeComplications != nil) {
            for complication in activeComplications! {
                complicationServer.reloadTimeline(for: complication)
            }
        }
    }
}
