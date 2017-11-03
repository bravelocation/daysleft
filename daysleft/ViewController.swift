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
    
    var dayChangeTimer: Timer!
    var shareButton: UIBarButtonItem!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)   {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.setupNotificationHandlers()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setupNotificationHandlers()
    }
        
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupNotificationHandlers() {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.iCloudSettingsUpdated(_:)), name: NSNotification.Name(rawValue: AppDaysLeftModel.iCloudSettingsNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ViewController.appEntersForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let model = self.modelData()
                
        // Customise the nav bar
        let navBar = self.navigationController?.navigationBar
        navBar!.barTintColor = UIColor(red: 53/255, green: 79/255, blue: 0/255, alpha: 1.0)
        navBar!.tintColor = UIColor.white
        navBar!.isTranslucent = false
        
        let titleDict: Dictionary<String, AnyObject> = [NSForegroundColorAttributeName: UIColor.white]
        navBar!.titleTextAttributes = titleDict
        
        // Add a share button
        self.shareButton = UIBarButtonItem.init(barButtonSystemItem: .action, target: self, action: #selector(ViewController.shareButtonTouchUp))
        
        self.navigationItem.leftBarButtonItem = shareButton
        
        // Add a swipe recogniser
        let swipeLeft : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.swipeLeft(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        // Add timer in case runs over a day change
        let now = Date()
        let secondsInADay: Double = 60 * 60 * 24
        let startOfTomorrow = model.AddDays(model.StartOfDay(now), daysToAdd: 1)
        self.dayChangeTimer = Timer(fireAt: startOfTomorrow, interval: secondsInADay, target: self, selector: #selector(ViewController.dayChangedTimerFired), userInfo: nil, repeats: false)
    }
 
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.counterView.clearControl()
        self.updateViewFromModel()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: nil, completion:{ context in self.counterView.updateControl() })
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if (previousTraitCollection == nil) {
            // Initialisation, so no need to update
            return
        }
        
        if (self.traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass || self.traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass) {
            self.counterView.updateControl()
        }
    }
    
    func dayChangedTimerFired(_ timer: Timer) {
        self.updateViewFromModel()
    }
    
    func updateViewFromModel() {
        NSLog("updateViewFromModel started")
        let model = self.modelData()
        
        let now: Date = Date()

        self.labelDaysLeft.text = String(format: "%d", model.DaysLeft(now))
        self.labelTitle.text = model.Description(now)

        let shortDateFormatter = DateFormatter()
        shortDateFormatter.dateFormat = "EEE d MMM"
        
        self.labelStartDate.text = String(format: "%@", shortDateFormatter.string(from: model.start))
        self.labelEndDate.text = String(format: "%@", shortDateFormatter.string(from: model.end))
        
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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.updateBadge()
        
        NSLog("updateViewFromModel completed")
    }

    func swipeLeft(_ gesture: UISwipeGestureRecognizer) {
        self.performSegue(withIdentifier: "segueShowSettings", sender: self)
    }
    
    func modelData() -> AppDaysLeftModel {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.model
    }
    
    func shareButtonTouchUp() {
        let modelText = self.modelData().FullDescription(Date())
        let objectsToShare = [modelText]
        
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
        if (activityViewController.popoverPresentationController != nil) {
                activityViewController.popoverPresentationController!.barButtonItem = self.shareButton;
        }
            
        self.present(activityViewController, animated: true, completion: nil)
    }

    @objc
    fileprivate func iCloudSettingsUpdated(_ notification: Notification) {
        NSLog("Received iCloud settings update notification in main view controller")
        
        // Update view data on main thread
        DispatchQueue.main.async {
            self.updateViewFromModel()
        }
    }
        
    @objc
    fileprivate func appEntersForeground() {
        NSLog("App enters foreground in main view controller")
        
        // Update view data on main thread
        DispatchQueue.main.async {
            self.counterView.clearControl()
            self.updateViewFromModel()
        }
    }
}

