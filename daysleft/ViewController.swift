//
//  ViewController.swift
//  daysleft
//
//  Created by John Pollard on 11/02/2015.
//  Copyright (c) 2015 Brave Location Software. All rights reserved.
//

import UIKit
import daysleftlibrary

class ViewController: UIViewController {

    @IBOutlet weak var labelDaysLeft: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var counterView: CounterView!
    @IBOutlet weak var labelStartDate: UILabel!
    @IBOutlet weak var labelEndDate: UILabel!
    @IBOutlet weak var labelPercentageDone: UILabel!
    
    let model: DaysLeftModel = DaysLeftModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check if this is the first run
        if (self.model.firstRun < self.model.currentFirstRun)
        {
            // If it is initialise the model dat
            self.model.start = NSDate()
            self.model.end = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.DayCalendarUnit, value: 30, toDate: self.model.start, options: nil)!
            self.model.title = ""
            self.model.weekdaysOnly = false
            
            // Save the first run once working
            self.model.firstRun = self.model.currentFirstRun
        }
        
        // Customise the nav bar
        let navBar = self.navigationController?.navigationBar
        navBar!.barTintColor = UIColor(red: 56/255, green: 111/255, blue: 29/255, alpha: 1.0)
        navBar!.tintColor = UIColor.whiteColor()
        navBar!.translucent = false
        
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navBar!.titleTextAttributes = titleDict as? [NSObject : AnyObject]
        
        // Add a swipe recogniser
        let swipeLeft : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeLeft:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.counterView.clearControl()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.updateViewFromModel()
    }
    
    @IBAction func returnFromSettings(segue: UIStoryboardSegue) {
    }
    
    func updateViewFromModel() {
        let now: NSDate = NSDate()
        self.labelDaysLeft.text = String(format: "%d", self.model.DaysLeft(now))
        
        let titleSuffix: String = (count(self.model.title) == 0 ? "left" : "until " + self.model.title)
        let titleDays: String = self.model.weekdaysOnly ? "weekdays" : "days"
        self.labelTitle.text = String(format: "%@ %@", titleDays, titleSuffix)

        var shortDateFormatter = NSDateFormatter()
        shortDateFormatter.dateFormat = "EEE d MMM"
        
        self.labelStartDate.text = String(format: "%@", shortDateFormatter.stringFromDate(self.model.start))
        self.labelEndDate.text = String(format: "%@", shortDateFormatter.stringFromDate(self.model.end))
        
        if (self.model.DaysLength == 0) {
            self.labelPercentageDone.text = ""
        }
        else {
            let percentageDone: Float = (Float(self.model.DaysGone(now)) * 100.0) / Float(self.model.DaysLength)
            self.labelPercentageDone.text = String(format:"%3.0f%% done", percentageDone)
        }
        
        self.counterView.counter = self.model.DaysGone(now)
        self.counterView.maximumValue = self.model.DaysLength
        self.counterView.updateControl()
    }

    func swipeLeft(gesture: UISwipeGestureRecognizer) {
        self.performSegueWithIdentifier("segueShowSettings", sender: self)
    }
}

