//
//  WatchDaysLeftData.swift
//  daysleft WatchKit Extension
//
//  Created by John Pollard on 13/11/2019.
//  Copyright © 2019 Brave Location Software. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import ClockKit

class WatchDaysLeftData: ObservableObject {
    
    @Published var currentPercentageLeft: String = ""
    @Published var currentTitle: String = ""
    @Published var currentSubTitle: String = ""
    @Published var percentageDone: Double = 0.0
    
    let modelChanged = PassthroughSubject<(), Never>()
    
    init() {
        // Add notification handler for updating on updated fixtures
        NotificationCenter.default.addObserver(self, selector: #selector(WatchDaysLeftData.userSettingsUpdated(_:)), name: NSNotification.Name(rawValue: AppSettingsDataManager.UpdateSettingsNotification), object: nil)
        
        self.updateViewData()
    }
    
    func updateViewData() {
        print("Updating view data...")
        
        // Reset the percentage done to 0.0
        self.percentageDone = 0.0
        self.modelChanged.send(())
        
        // Set the published properties based on the model
        let now: Date = Date()
        let appSettings = AppSettingsDataManager().appSettings
        
        self.currentTitle = "\(appSettings.daysLeftDescription(now)) until"
        self.currentSubTitle = appSettings.title

        let percentageDone: Double = (Double(appSettings.daysGone(now)) * 100.0) / Double(appSettings.daysLength)
        self.percentageDone = percentageDone
        self.currentPercentageLeft = String(format: "%3.0f%% done", percentageDone)
        self.modelChanged.send(())
        
        // Let's update the snapshot if the view changed
        print("Scheduling snapshot")
        
        let soon =  Calendar.current.date(byAdding: .second, value: 5, to: Date())
        WKExtension.shared().scheduleSnapshotRefresh(withPreferredDate: soon!, userInfo: nil, scheduledCompletion: { (error: Error?) in
            if let error = error {
                print("Error occurred while scheduling snapshot: \(error.localizedDescription)")
            }})
    }
    
    @objc
    fileprivate func userSettingsUpdated(_ notification: Notification) {
        print("Received UserSettingsUpdated notification")
        
        // Update view data on main thread
        DispatchQueue.main.async {
            self.updateViewData()
        }
        
        // Let's also update the complications if the data has changed
        let complicationServer = CLKComplicationServer.sharedInstance()
        let activeComplications = complicationServer.activeComplications
        
        if (activeComplications != nil) {
            for complication in activeComplications! {
                complicationServer.reloadTimeline(for: complication)
            }
        }
    }
}
