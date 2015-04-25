//
//  InterfaceController.swift
//  daysleft WatchKit Extension
//
//  Created by John Pollard on 22/03/2015.
//  Copyright (c) 2015 Brave Location Software. All rights reserved.
//

import WatchKit
import Foundation
import daysleftlibrary

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var labelTitle: WKInterfaceLabel!
    @IBOutlet weak var labelPercentDone: WKInterfaceLabel!
    @IBOutlet weak var imageProgress: WKInterfaceImage!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        self.updateViewData()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    
    private func updateViewData() {
        let now: NSDate = NSDate()
        let model: DaysLeftModel = DaysLeftModel()
        let daysLeft: Int = model.DaysLeft(now)
        let titleSuffix: String = (count(model.title) == 0 ? "left" : "until " + model.title)
        let titleDays: String = model.weekdaysOnly ? "weekdays" : "days"
        
        self.labelTitle.setText(String(format: "%d %@ %@", daysLeft, titleDays, titleSuffix))
        
        let percentageDone: Float = (Float(model.DaysGone(now)) * 100.0) / Float(model.DaysLength)
        self.labelPercentDone.setText(String(format:"%3.0f%% done", percentageDone))
        
        // Set the progress image set
        let intPercentageDone: Int = Int(percentageDone)
        self.imageProgress.setImageNamed("progress")
        self.imageProgress.startAnimatingWithImagesInRange(NSRange(location:0, length: intPercentageDone), duration: 0.5, repeatCount: 1)
    }
}
