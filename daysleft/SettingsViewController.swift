//
//  SettingsViewController.swift
//  daysleft
//
//  Created by John Pollard on 17/02/2015.
//  Copyright (c) 2015 Brave Location Software. All rights reserved.
//

import UIKit
import daysleftlibrary

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textTitle: UITextField!
    @IBOutlet weak var textStart: UITextField!
    @IBOutlet weak var textEnd: UITextField!
    @IBOutlet weak var switchWeekdaysOnly: UISwitch!
    @IBOutlet weak var buttonStartToday: UIButton!
    @IBOutlet weak var labelDaysLength: UILabel!
    
    var model: DaysLeftModel = DaysLeftModel()
    var dateFormatter: NSDateFormatter = NSDateFormatter()
    
    let startDatePicker : UIDatePicker = UIDatePicker();
    let endDatePicker : UIDatePicker = UIDatePicker();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textTitle.text = model.title
        self.switchWeekdaysOnly.on = model.weekdaysOnly
        
        // Setup date formatter
        self.dateFormatter.dateFormat = "EEE d MMM YYYY"
        
        self.textStart.text = String(format: "%@", self.dateFormatter.stringFromDate(self.model.start))
        self.textEnd.text = String(format: "%@", self.dateFormatter.stringFromDate(self.model.end))
        self.labelDaysLength.text = String(format: "%d days", self.model.DaysLength)
        
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
    }
    
    @IBAction func textTitleChanged(sender: AnyObject) {
        model.title = self.textTitle.text
    }
    
    @IBAction func dateChanged(sender: AnyObject) {
        self.validateAndSaveDates()
    }
    
    @IBAction func switchWeekdaysOnlyChanged(sender: AnyObject) {
        model.weekdaysOnly = self.switchWeekdaysOnly.on
        self.validateAndSaveDates()
    }
    
    @IBAction func buttonStartTodayTouchUp(sender: AnyObject) {
        self.startDatePicker.date = NSDate()
        self.validateAndSaveDates()
    }
    
    // Hides the keyboard if touch anywhere outside text box
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    // Hides the keyboard if return is pressed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    
    func validateAndSaveDates() {
        // Update the model
        model.start = self.startDatePicker.date
        model.end = self.endDatePicker.date
        
        // Update the text fields
        self.textStart.text = String(format: "%@", self.dateFormatter.stringFromDate(self.model.start))
        self.textEnd.text = String(format: "%@", self.dateFormatter.stringFromDate(self.model.end))
        self.labelDaysLength.text = String(format: "%d days", self.model.DaysLength)
        
        // Update the date restrictions too
        self.startDatePicker.maximumDate = model.end
        self.endDatePicker.minimumDate = model.start
    }
}

