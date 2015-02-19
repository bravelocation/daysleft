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
    @IBOutlet weak var counterView: CounterView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.preferredContentSize = CGSizeMake(0, 100)
        self.updateViewData()
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        self.updateViewData()
        completionHandler(NCUpdateResult.NewData)
    }
    
    private func updateViewData() {
        let now: NSDate = NSDate()
        let model: DaysLeftModel = DaysLeftModel()
        let daysLeft: Int = model.DaysLeft(now)
        let titleSuffix: String = (count(model.title) == 0 ? "left" : "until " + model.title)
        let titleDays: String = model.weekdaysOnly ? "weekdays" : "days"
        
        self.labelNumberTitle.text = String(format: "%d %@ %@", daysLeft, titleDays, titleSuffix)
                
        self.counterView.counter = model.DaysGone(now)
        self.counterView.maximumValue = model.DaysLength
        self.counterView.setNeedsDisplay()

    }
}
