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
        self.preferredContentSize = CGSizeMake(0, 100)
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
    }
}
