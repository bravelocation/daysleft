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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.updateViewData()
    }
    
    func widgetMarginInsetsForProposedMarginInsets (defaultMarginInsets: UIEdgeInsets) -> (UIEdgeInsets) {
        return UIEdgeInsetsZero
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        self.updateViewData()
        completionHandler(NCUpdateResult.NewData)
    }
    
    private func updateViewData() {
        let model: DaysLeftModel = DaysLeftModel()
        let daysLeft: Int = model.DaysLeft(NSDate())
        let titleSuffix: String = (count(model.title) == 0 ? "left" : "until " + model.title)
        let titleDays: String = model.weekdaysOnly ? "weekdays" : "days"
        
        self.labelNumberTitle.text = String(format: "%d %@ %@", daysLeft, titleDays, titleSuffix)
    }
}
