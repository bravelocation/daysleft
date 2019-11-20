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

class WatchDaysLeftData: ObservableObject {
    
    @Published var currentPercentageLeft: String = ""
    @Published var currentTitle: String = ""
    @Published var currentSubTitle: String = ""
    @Published var percentageDone: Double = 0.0
    
    let modelChanged = PassthroughSubject<(), Never>()
    
    init() {
        //Add notification handler for updating on updated fixtures
        NotificationCenter.default.addObserver(self, selector: #selector(WatchDaysLeftData.userSettingsUpdated(_:)), name: NSNotification.Name(rawValue: BLUserSettings.UpdateSettingsNotification), object: nil)
        
        self.updateViewData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func updateViewData() {
        NSLog("Updating view data...")
        
        // Reset the percentage done to 0.0
        self.percentageDone = 0.0
        self.modelChanged.send(())
        
        // Set the published properties based on the model
        let now: Date = Date()
        let appDelegate = WKExtension.shared().delegate as! ExtensionDelegate
        let model = appDelegate.model
        
        self.currentTitle = "\(model.daysLeftDescription(now)) until"
        self.currentSubTitle = model.title

        let percentageDone: Double = (Double(model.daysGone(now)) * 100.0) / Double(model.daysLength)
        self.percentageDone = percentageDone
        self.currentPercentageLeft = String(format: "%3.0f%% done", percentageDone)
        self.modelChanged.send(())
        
        // Let's also update the complications if the data has changed
        model.updateComplications()
        
        // Let's update the snapshot if the view changed
        print("Scheduling snapshot")
        
        let soon =  (Calendar.autoupdatingCurrent as NSCalendar).date(byAdding: .second, value: 5, to: Date(), options: [])
        WKExtension.shared().scheduleSnapshotRefresh(withPreferredDate: soon!, userInfo: nil, scheduledCompletion: { (error: Error?) in
            if let error = error {
                print("Error occurred while scheduling snapshot: \(error.localizedDescription)")
            }})
    }
    
    @objc
    fileprivate func userSettingsUpdated(_ notification: Notification) {
        NSLog("Received BLUserSettingsUpdated notification")
        
        // Update view data on main thread
        DispatchQueue.main.async {
            self.updateViewData()
        }
    }
}
