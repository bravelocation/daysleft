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
    @IBOutlet weak var counterWidth: NSLayoutConstraint!
    
    var dayChangeTimer: NSTimer!
    var shareButton: UIBarButtonItem!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)   {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.iCloudSettingsUpdated(_:)), name: DaysLeftModel.iCloudSettingsNotification, object: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.iCloudSettingsUpdated(_:)), name: DaysLeftModel.iCloudSettingsNotification, object: nil)
    }
        
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let model = self.modelData()
                
        // Customise the nav bar
        let navBar = self.navigationController?.navigationBar
        navBar!.barTintColor = UIColor(red: 53/255, green: 79/255, blue: 0/255, alpha: 1.0)
        navBar!.tintColor = UIColor.whiteColor()
        navBar!.translucent = false
        
        let titleDict: Dictionary<String, AnyObject> = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navBar!.titleTextAttributes = titleDict
        
        // Add a share button
        self.shareButton = UIBarButtonItem.init(barButtonSystemItem: .Action, target: self, action: #selector(ViewController.shareButtonTouchUp))
        
        self.navigationItem.leftBarButtonItem = shareButton
        
        // Add a swipe recogniser
        let swipeLeft : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.swipeLeft(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        
        // Add timer in case runs over a day change
        let now = NSDate()
        let secondsInADay: Double = 60 * 60 * 24
        let startOfTomorrow = model.AddDays(model.StartOfDay(now), daysToAdd: 1)
        self.dayChangeTimer = NSTimer(fireDate: startOfTomorrow, interval: secondsInADay, target: self, selector: #selector(ViewController.dayChangedTimerFired), userInfo: nil, repeats: false)
    }
 
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.counterView.clearControl()
        self.updateViewFromModel()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

        coordinator.animateAlongsideTransition(nil, completion:{ context in self.counterView.updateControl() })
    }

    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if (previousTraitCollection == nil) {
            // Initialisation, so no need to update
            return
        }
        
        if (self.traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass || self.traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass) {
            self.counterView.updateControl()
        }
    }
    
    func dayChangedTimerFired(timer: NSTimer) {
        self.updateViewFromModel()
    }
    
    func updateViewFromModel() {
        NSLog("updateViewFromModel started")
        let model = self.modelData()
        
        let now: NSDate = NSDate()

        self.labelDaysLeft.text = String(format: "%d", model.DaysLeft(now))
        self.labelTitle.text = model.Description(now)

        let shortDateFormatter = NSDateFormatter()
        shortDateFormatter.dateFormat = "EEE d MMM"
        
        self.labelStartDate.text = String(format: "%@", shortDateFormatter.stringFromDate(model.start))
        self.labelEndDate.text = String(format: "%@", shortDateFormatter.stringFromDate(model.end))
        
        if (model.DaysLength == 0) {
            self.labelPercentageDone.text = ""
        }
        else {
            let percentageDone: Float = (Float(model.DaysGone(now)) * 100.0) / Float(model.DaysLength)
            self.labelPercentageDone.text = String(format:"%3.0f%% done", percentageDone)
        }
        
        self.counterView.counter = model.DaysGone(now)
        self.counterView.maximumValue = model.DaysLength
        self.counterView.updateControl()
        
        // Update the badge too
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.updateBadge()
        
        NSLog("updateViewFromModel completed")
    }

    func swipeLeft(gesture: UISwipeGestureRecognizer) {
        self.performSegueWithIdentifier("segueShowSettings", sender: self)
    }
    
    func modelData() -> DaysLeftModel {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.model
    }
    
    func shareButtonTouchUp() {
        let modelText = self.modelData().FullDescription(NSDate())
        let objectsToShare = [modelText]
        
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
        if (activityViewController.popoverPresentationController != nil) {
                activityViewController.popoverPresentationController!.barButtonItem = self.shareButton;
        }
            
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }

    @objc
    private func iCloudSettingsUpdated(notification: NSNotification) {
        NSLog("Received iCloud settings update notification in main view controller")
        
        // Update view data on main thread
        dispatch_async(dispatch_get_main_queue()) {
            self.updateViewFromModel()
        }
    }
}

