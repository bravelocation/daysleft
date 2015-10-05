//
//  InterfaceController.swift
//  daysleft WatchKit Extension
//
//  Created by John Pollard on 22/03/2015.
//  Copyright (c) 2015 Brave Location Software. All rights reserved.
//

import WatchKit
import Foundation
import daysleftwatchlibrary

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var labelTitle: WKInterfaceLabel!
    @IBOutlet weak var labelPercentDone: WKInterfaceLabel!
    @IBOutlet weak var imageProgress: WKInterfaceImage!
    
    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userSettingsUpdated:", name: BLUserSettings.UpdateSettingsNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        NSLog("InterfaceController.willActivate() started")
        
        super.willActivate()
        self.updateViewData()
        
        NSLog("InterfaceController.willActivate() ended")
    }
    
    private func updateViewData() {
        let now: NSDate = NSDate()
        let model = modelData()
        
        let daysLeft: Int = model.DaysLeft(now)
        let titleSuffix: String = (model.title.characters.count == 0 ? "left" : "until " + model.title)
        let titleDays: String = model.weekdaysOnly ? "weekdays" : "days"
        
        self.labelTitle.setText(String(format: "%d %@ %@", daysLeft, titleDays, titleSuffix))
        
        let percentageDone: Float = (Float(model.DaysGone(now)) * 100.0) / Float(model.DaysLength)
        self.labelPercentDone.setText(String(format:"%3.0f%% done", percentageDone))
        
        // Set the progress image set
        let intPercentageDone: Int = Int(percentageDone)
        self.imageProgress.setImageNamed("progress")
        self.imageProgress.startAnimatingWithImagesInRange(NSRange(location:0, length: intPercentageDone), duration: 0.5, repeatCount: 1)
    }
    
    @objc
    private func userSettingsUpdated(notification: NSNotification) {
        print("Received BLUserSettingsUpdated notification")
        
        // Update view data on main thread
        dispatch_async(dispatch_get_main_queue()) {
            self.updateViewData()
        }
    }
    
    func modelData() -> DaysLeftModel {
        let appDelegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate
        return appDelegate.model!
    }
}
