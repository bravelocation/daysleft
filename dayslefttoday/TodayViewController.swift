//
//  TodayViewController.swift
//  dayslefttoday
//
//  Created by John Pollard on 18/02/2015.
//  Copyright (c) 2015 Brave Location Software. All rights reserved.
//

import UIKit
import NotificationCenter
import daysleftlibrary

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var labelNumberTitle: UILabel!
    @IBOutlet weak var labelPercentDone: UILabel!
    @IBOutlet weak var counterView: CounterView!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.counterView.clearControl()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.updateViewData()
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        self.updateViewData()
        completionHandler(NCUpdateResult.NewData)
    }
    
    private func updateViewData() {
        let now: NSDate = NSDate()
        let model: DaysLeftModel = DaysLeftModel()
        
        self.labelNumberTitle.text = model.FullDescription(now)
 
        let percentageDone: Float = (Float(model.DaysGone(now)) * 100.0) / Float(model.DaysLength)
        self.labelPercentDone.text = String(format:"%3.0f%% done", percentageDone)

        self.counterView.counter = model.DaysGone(now)
        self.counterView.maximumValue = model.DaysLength
        self.counterView.updateControl()
        
        // Set widget colors based on version of iOS
        let ios10AndAbove:Bool = NSProcessInfo.processInfo().isOperatingSystemAtLeastVersion(NSOperatingSystemVersion(majorVersion: 10, minorVersion: 0, patchVersion: 0))

        if (ios10AndAbove) {
            let darkGreen = UIColor(red: 53.0/255.0, green: 79.0/255.0, blue: 0.0, alpha: 1.0)
            let lightTransparentColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.8)
            
            self.view.backgroundColor = lightTransparentColor
            self.labelNumberTitle.textColor = darkGreen
            self.labelPercentDone.textColor = darkGreen
        } else {
            self.view.backgroundColor = UIColor.clearColor()
            self.labelNumberTitle.textColor = UIColor.whiteColor()
            self.labelPercentDone.textColor = UIColor.whiteColor()
        }
    }
}
