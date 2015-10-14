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

public class WatchDaysLeftModel: DaysLeftModel
{
    public override init() {
        super.init()
        self.updateCompications()
    }
    
    /// Send updated settings to watch
    public override func initialiseiCloudSettings() {
        // Don't setup iCloud on watch!
    }
    
    /// Write settings to iCloud store
    public override func writeSettingToiCloudStore(value: AnyObject, key: String) {
        // Don't write settings to iCloud when on watch!
    }

    public override func pushSettingChangeToWatch(key : String) {
        // Don't send settings to watch when on watch!
    }
    
    /// Send initial settings to watch
    public override func pushAllSettingsToWatch() {
        // Don't send settings to watch when on watch!
    }
    
    public override func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        super.session(session, didReceiveUserInfo: userInfo)
        self.updateCompications()
    }
    
    func updateCompications() {
        NSLog("Updating complications...")
        let complicationServer = CLKComplicationServer.sharedInstance()
        if (complicationServer != nil) {
            for complication in complicationServer.activeComplications {
                complicationServer.reloadTimelineForComplication(complication)
            }
        }
    }
}