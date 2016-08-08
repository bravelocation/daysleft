//
//  SettingsViewController.swift
//  daysleft
//
//  Created by John Pollard on 17/02/2015.
//  Copyright (c) 2015 Brave Location Software. All rights reserved.
//

import UIKit
import SafariServices
import daysleftlibrary

class SettingsViewController: UITableViewController, UITextFieldDelegate, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var textTitle: UITextField!
    @IBOutlet weak var textStart: UITextField!
    @IBOutlet weak var textEnd: UITextField!
    @IBOutlet weak var switchWeekdaysOnly: UISwitch!
    @IBOutlet weak var buttonStartToday: UIButton!
    @IBOutlet weak var labelDaysLength: UILabel!
    @IBOutlet weak var labelVersion: UILabel!
    @IBOutlet weak var switchShowBadge: UISwitch!
    
    var dateFormatter: NSDateFormatter = NSDateFormatter()
    
    let startDatePicker : UIDatePicker = UIDatePicker();
    let endDatePicker : UIDatePicker = UIDatePicker();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let model = self.modelData()

        self.textTitle.text = model.title
        self.switchWeekdaysOnly.on = model.weekdaysOnly
        self.switchShowBadge.on = model.showBadge
        
        // Setup date formatter
        self.dateFormatter.dateFormat = "EEE d MMM YYYY"
        
        self.textStart.text = String(format: "%@", self.dateFormatter.stringFromDate(model.start))
        self.textEnd.text = String(format: "%@", self.dateFormatter.stringFromDate(model.end))
        self.labelDaysLength.text = String(format: "%d days", model.DaysLength)
        
        // Setup the date pickers as editors for text fields
        self.startDatePicker.date = model.start
        self.startDatePicker.maximumDate = model.end
        self.startDatePicker.datePickerMode = UIDatePickerMode.Date
        self.startDatePicker.addTarget(self, action: #selector(SettingsViewController.dateChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.textStart.inputView = self.startDatePicker
        
        self.endDatePicker.date = model.end
        self.endDatePicker.minimumDate = model.start
        self.endDatePicker.datePickerMode = UIDatePickerMode.Date
        self.endDatePicker.addTarget(self, action: #selector(SettingsViewController.dateChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.textEnd.inputView = self.endDatePicker

        // Set up the delegate of text field for handling return below
        self.textTitle.delegate = self
        
        // Add version number
        let infoDictionary = NSBundle.mainBundle()
        let version = infoDictionary.objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        let build = infoDictionary.objectForInfoDictionaryKey("CFBundleVersion") as! String
        self.labelVersion.text = String(format: "v%@.%@", version, build)
    }

    @IBAction func textTitleChanged(sender: AnyObject) {
        self.validateAndSaveModel()
    }
    
    func dateChanged(sender: AnyObject) {
        self.validateAndSaveModel()
    }
    
    @IBAction func switchWeekdaysOnlyChanged(sender: AnyObject) {
        self.validateAndSaveModel()
    }
 
    @IBAction func switchShowBadgeChanged(sender: AnyObject) {
        let model = self.modelData()
        model.showBadge = self.switchShowBadge.on

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.registerForNotifications()
    }
    
    @IBAction func buttonStartTodayTouchUp(sender: AnyObject) {
        let model = self.modelData()

        model.weekdaysOnly = false
        self.switchWeekdaysOnly.on = false
        
        self.startDatePicker.date = NSDate()
        self.endDatePicker.date = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: 30, toDate: NSDate(), options: [])!
        self.validateAndSaveModel()
    }
    
    // Hides the keyboard if touch anywhere outside text box
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.view.endEditing(true)
        
        if (indexPath.section == 4) {
            var url: NSURL? = nil;
            
            if (indexPath.row == 0) {
                url = NSURL(string: "http://www.bravelocation.com/countthedaysleft")!
            }
            else if (indexPath.row == 1) {
                url = NSURL(string: "http://github.com/bravelocation/daysleft")!
            }
            else if (indexPath.row == 2) {
                url = NSURL(string: "http://www.bravelocation.com/apps")!
            }
            
            if (url != nil) {
                let svc = SFSafariViewController(URL: url!)
                svc.delegate = self
                self.presentViewController(svc, animated: true, completion: nil)
            }
        }
    }
    
    // Hides the keyboard if return is pressed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    
    func validateAndSaveModel() {
        // Update the model
        let model = self.modelData()

        model.start = self.startDatePicker.date
        model.end = self.endDatePicker.date
        model.weekdaysOnly = self.switchWeekdaysOnly.on
        model.title = self.textTitle!.text!
        
        // Update the text fields
        self.textStart.text = String(format: "%@", self.dateFormatter.stringFromDate(model.start))
        self.textEnd.text = String(format: "%@", self.dateFormatter.stringFromDate(model.end))
        self.labelDaysLength.text = String(format: "%d days", model.DaysLength)
        
        // Update the date restrictions too
        self.startDatePicker.maximumDate = model.end
        self.endDatePicker.minimumDate = model.start
        
        // Update the badge too
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.updateBadge()
        
        // Push any changes to watch
        model.pushAllSettingsToWatch()
    }
    
    func modelData() -> DaysLeftModel {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.model
    }
    
    // MARK: - SFSafariViewControllerDelegate methods
    func safariViewControllerDidFinish(controller: SFSafariViewController)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

