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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.counterView.clearControl()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateViewData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add tap handler to everything
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapHandler(_:)))
        self.labelNumberTitle.addGestureRecognizer(tapGesture)
        self.labelPercentDone.addGestureRecognizer(tapGesture)
        self.counterView.addGestureRecognizer(tapGesture)
        self.view.addGestureRecognizer(tapGesture)
        
        self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if (activeDisplayMode == NCWidgetDisplayMode.compact) {
            self.preferredContentSize = maxSize
        } else {
            self.preferredContentSize = CGSize(width: maxSize.width, height: 140)
        }
        
        self.view.layoutIfNeeded()
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        self.updateViewData()
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    @objc
    func tapHandler(_ sender: UITapGestureRecognizer) {
        let url = URL(fileURLWithPath: "daysleft://")
        self.extensionContext?.open(url, completionHandler: nil)
    }
    
    fileprivate func updateViewData() {
        let now: Date = Date()
        let model: DaysLeftModel = DaysLeftModel()
        
        self.labelNumberTitle.text = model.fullDescription(now)
 
        let percentageDone: Float = (Float(model.daysGone(now)) * 100.0) / Float(model.daysLength)
        self.labelPercentDone.text = String(format: "%3.0f%% done", percentageDone)

        self.counterView.counter = model.daysGone(now)
        self.counterView.maximumValue = model.daysLength
        self.counterView.updateControl()
        
        // Set widget colors
        self.view.backgroundColor = UIColor.clear
        self.labelNumberTitle.textColor = UIColor(named: "TodayTextColor")
        self.labelPercentDone.textColor = UIColor(named: "TodayTextColor")
    }
}
