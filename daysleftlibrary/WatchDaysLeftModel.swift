//
//  WatchDaysLeftModel.swift
//  daysleft
//
//  Created by John Pollard on 03/10/2015.
//  Copyright © 2015 Brave Location Software. All rights reserved.
//

import Foundation
import WatchConnectivity

public class WatchDaysLeftModel: DaysLeftModel
{
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
}