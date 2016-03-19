//
//  SettingsViewController.swift
//  daysleft
//
//  Created by John Pollard on 17/02/2015.
//  Copyright (c) 2015 Brave Location Software. All rights reserved.
//

import UIKit
import daysleftlibrary

class SettingsViewController: UITableViewController, UITextFieldDelegate {
    
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
        self.startDatePicker.addTarget(self, action: "dateChanged:", forControlEvents: UIControlEvents.ValueChanged)
        self.textStart.inputView = self.startDatePicker
        
        self.endDatePicker.date = model.end
        self.endDatePicker.minimumDate = model.start
        self.endDatePicker.datePickerMode = UIDatePickerMode.Date
        self.endDatePicker.addTarget(self, action: "dateChanged:", forControlEvents: UIControlEvents.ValueChanged)
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
        let model = self.modelData()
        model.title = self.textTitle.text!
    }
    
    func dateChanged(sender: AnyObject) {
        self.validateAndSaveDates()
    }
    
    @IBAction func switchWeekdaysOnlyChanged(sender: AnyObject) {
        let model = self.modelData()

        model.weekdaysOnly = self.switchWeekdaysOnly.on
        self.validateAndSaveDates()
    }
 
    @IBAction func switchShowBadgeChanged(sender: AnyObject) {
        let model = self.modelData()
        model.showBadge = self.switchShowBadge.on

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        if (model.showBadge) {
            appDelegate.registerForNotifications()
            appDelegate.updateBadge()
        } else {
            appDelegate.clearBadge()
        }
    }
    
    @IBAction func buttonStartTodayTouchUp(sender: AnyObject) {
        let model = self.modelData()

        model.weekdaysOnly = false
        self.switchWeekdaysOnly.on = false
        
        self.startDatePicker.date = NSDate()
        self.endDatePicker.date = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: 30, toDate: NSDate(), options: [])!
        self.validateAndSaveDates()
    }
    
    // Hides the keyboard if touch anywhere outside text box
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.view.endEditing(true)
        
        if (indexPath.section == 4) {
            if (indexPath.row == 0) {
                let url: NSURL = NSURL(string: "http://www.bravelocationstudios.com")!
                if (UIApplication.sharedApplication().openURL(url) == false) {
                    NSLog("Failed to open %@", url)
                }
            }
            else if (indexPath.row == 1) {
                let url: NSURL = NSURL(string: "http://www.bravelocation.com/countthedaysleft")!
                if (UIApplication.sharedApplication().openURL(url) == false) {
                    NSLog("Failed to open %@", url)
               }
            }
            else if (indexPath.row == 2) {
                let url: NSURL = NSURL(string: "http://github.com/bravelocation/daysleft")!
                if (UIApplication.sharedApplication().openURL(url) == false) {
                    NSLog("Failed to open %@", url)
                }
            }
        }
    }
    
    // Hides the keyboard if return is pressed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    
    func validateAndSaveDates() {
        // Update the model
        let model = self.modelData()

        model.start = self.startDatePicker.date
        model.end = self.endDatePicker.date
        
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
    }
    
    func modelData() -> DaysLeftModel {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.model
    }
}

