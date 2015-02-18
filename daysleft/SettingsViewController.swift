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
    @IBOutlet weak var dateEnd: UIDatePicker!
    @IBOutlet weak var dateStart: UIDatePicker!
    @IBOutlet weak var switchWeekdaysOnly: UISwitch!
    
    var model: DaysLeftModel = DaysLeftModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textTitle.text = model.title
        self.dateEnd.date = model.end
        self.dateStart.date = model.start
        self.switchWeekdaysOnly.on = model.weekdaysOnly
        
        // Don't let the start date be later than the end date
        self.dateStart.maximumDate = self.dateEnd.date
        self.dateEnd.minimumDate = self.dateStart.date
        
        // Set up the delegate of text field for handling return below
        self.textTitle.delegate = self
    }
    
    @IBAction func textTitleChanged(sender: AnyObject) {
        model.title = self.textTitle.text
    }
    
    @IBAction func dateEndChanged(sender: AnyObject) {
        self.validateAndSaveDates()
    }
    
    @IBAction func dateStartChanged(sender: AnyObject) {
        self.validateAndSaveDates()
    }

    @IBAction func switchWeekdaysOnlyChanged(sender: AnyObject) {
        model.weekdaysOnly = self.switchWeekdaysOnly.on
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
        model.start = self.dateStart.date
        model.end = self.dateEnd.date
            
        // Update the date restrictions too
        self.dateStart.maximumDate = self.dateEnd.date
        self.dateEnd.minimumDate = self.dateStart.date
    }
}

