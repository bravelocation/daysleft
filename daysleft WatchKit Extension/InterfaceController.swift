//
//  InterfaceController.swift
//  daysleft WatchKit Extension
//
//  Created by John Pollard on 22/03/2015.
//  Copyright (c) 2015 Brave Location Software. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var labelTitle: WKInterfaceLabel!
    @IBOutlet weak var labelPercentDone: WKInterfaceLabel!
    @IBOutlet weak var imageProgress: WKInterfaceImage!
    
    var currentDaysLeft: Int = -1;
    var currentWeekdaysOnly = false;
    var currentTitle = ""
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(InterfaceController.userSettingsUpdated(_:)), name: NSNotification.Name(rawValue: BLUserSettings.UpdateSettingsNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.updateViewData()
    }
    
    override func willActivate() {
        super.willActivate()
        self.updateViewData()
    }
    
    fileprivate func updateViewData() {
        NSLog("Updating view data...")
        
        let now: Date = Date()
        let appDelegate = WKExtension.shared().delegate as! ExtensionDelegate
        let model = appDelegate.model
        
        // Do we need to update the view?
        let daysLeft = model.DaysLeft(now);
        let weekdaysOnly = model.weekdaysOnly
        let title = model.title
        
        if (daysLeft == self.currentDaysLeft && currentWeekdaysOnly == weekdaysOnly && currentTitle.compare(title) == ComparisonResult.orderedSame) {
            NSLog("View unchanged")
            return;
        }
        
        self.currentDaysLeft = daysLeft
        self.currentWeekdaysOnly = weekdaysOnly
        self.currentTitle = title
        
        self.labelTitle.setText(model.FullDescription(now))
        
        let percentageDone: Float = (Float(model.DaysGone(now)) * 100.0) / Float(model.DaysLength)
        self.labelPercentDone.setText(String(format:"%3.0f%% done", percentageDone))
        
        // Set the progress image set
        let intPercentageDone: Int = Int(percentageDone)
        self.imageProgress.setImageNamed("progress")
        self.imageProgress.startAnimatingWithImages(in: NSRange(location:0, length: intPercentageDone), duration: 0.5, repeatCount: 1)
        NSLog("View updated")
        
        // Let's also update the complications if the data has changed
        model.updateComplications()
        
        // Let's update the snapshot if the view changed
        print("Scheduling snapshot")
        
        let soon =  (Calendar.autoupdatingCurrent as NSCalendar).date(byAdding: .second, value: 5, to: Date(), options: [])
        WKExtension.shared().scheduleSnapshotRefresh(withPreferredDate: soon!, userInfo: nil, scheduledCompletion: { (error: NSError?) in
            if let error = error {
                print("Error occurred while scheduling snapshot: \(error.localizedDescription)")
            }} as! (Error?) -> Void)
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
