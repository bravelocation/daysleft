//
//  DateSelectorViewController.swift
//  DaysLeft
//
//  Created by John Pollard on 23/08/2020.
//  Copyright © 2020 Brave Location Software. All rights reserved.
//

import UIKit

class DateSelectorViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var model: AppDaysLeftModel!
    var isStartDate: Bool = true
    var completion: () -> Void
    
    init(model: AppDaysLeftModel, isStartDate: Bool, completion: @escaping () -> Void) {
        self.model = model
        self.isStartDate = isStartDate
        self.completion = completion
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        self.completion = {}
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel.text = self.isStartDate ? "Start Date" : "End Date"
        self.datePicker.date = self.isStartDate ? model.start : model.end
        
        if self.isStartDate {
            self.datePicker.maximumDate = model.end
        } else {
            self.datePicker.minimumDate = model.start
        }
    }

    @IBAction func cancelButtonTouchUp(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func okButtonTouchUp(_ sender: Any) {
        if (self.isStartDate) {
            self.model.start = self.datePicker.date
        } else {
            self.model.end = self.datePicker.date
        }
        
        self.completion()
        self.dismiss(animated: true, completion: nil)
    }
}
