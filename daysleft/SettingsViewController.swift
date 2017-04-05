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
import GoogleMobileAds
import Firebase

class SettingsViewController: UITableViewController, UITextFieldDelegate, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var textTitle: UITextField!
    @IBOutlet weak var textStart: UITextField!
    @IBOutlet weak var textEnd: UITextField!
    @IBOutlet weak var switchWeekdaysOnly: UISwitch!
    @IBOutlet weak var buttonStartToday: UIButton!
    @IBOutlet weak var labelDaysLength: UILabel!
    @IBOutlet weak var labelVersion: UILabel!
    @IBOutlet weak var switchShowBadge: UISwitch!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var adCell: UITableViewCell!
    @IBOutlet weak var removeAdsCell: UITableViewCell!
    
    var dateFormatter: DateFormatter = DateFormatter()
    
    let startDatePicker : UIDatePicker = UIDatePicker();
    let endDatePicker : UIDatePicker = UIDatePicker();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let model = self.modelData()

        self.textTitle.text = model.title
        self.switchWeekdaysOnly.isOn = model.weekdaysOnly
        self.switchShowBadge.isOn = model.showBadge
        
        // Setup date formatter
        self.dateFormatter.dateFormat = "EEE d MMM YYYY"
        
        self.textStart.text = String(format: "%@", self.dateFormatter.string(from: model.start))
        self.textEnd.text = String(format: "%@", self.dateFormatter.string(from: model.end))
        self.labelDaysLength.text = model.DaysLeftDescription(model.start)
        
        // Setup the date pickers as editors for text fields
        self.startDatePicker.date = model.start
        self.startDatePicker.maximumDate = model.end
        self.startDatePicker.datePickerMode = UIDatePickerMode.date
        self.startDatePicker.addTarget(self, action: #selector(SettingsViewController.dateChanged(_:)), for: UIControlEvents.valueChanged)
        self.textStart.inputView = self.startDatePicker
        
        self.endDatePicker.date = model.end
        self.endDatePicker.minimumDate = model.start
        self.endDatePicker.datePickerMode = UIDatePickerMode.date
        self.endDatePicker.addTarget(self, action: #selector(SettingsViewController.dateChanged(_:)), for: UIControlEvents.valueChanged)
        self.textEnd.inputView = self.endDatePicker

        // Set up the delegate of text field for handling return below
        self.textTitle.delegate = self
        
        // Setup ads
        self.bannerView.adUnitID = "ca-app-pub-6795405439060738/6923889836"
        self.bannerView.rootViewController = self
        
        // Add version number
        let infoDictionary = Bundle.main
        let version = infoDictionary.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build = infoDictionary.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        self.labelVersion.text = String(format: "v%@.%@", version, build)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show the ads if not hidden
        if (self.showAds()) {
            let request = GADRequest()
            
            #if DEBUG
                request.testDevices = [kGADSimulatorID]
            #endif
            
            self.bannerView.load(request)
            
            self.bannerView.isHidden = false
            self.adCell.isHidden = false
            self.removeAdsCell.isHidden = false
        } else {
            self.bannerView.isHidden = true
            self.adCell.isHidden = true
            self.removeAdsCell.isHidden = true
        }
    }

    @IBAction func textTitleChanged(_ sender: AnyObject) {
        self.validateAndSaveModel()
    }
    
    func dateChanged(_ sender: AnyObject) {
        self.validateAndSaveModel()
    }
    
    @IBAction func switchWeekdaysOnlyChanged(_ sender: AnyObject) {
        self.validateAndSaveModel()
    }
 
    @IBAction func switchShowBadgeChanged(_ sender: AnyObject) {
        let model = self.modelData()
        model.showBadge = self.switchShowBadge.isOn

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.registerForNotifications()
    }
    
    @IBAction func buttonStartTodayTouchUp(_ sender: AnyObject) {
        let model = self.modelData()

        model.weekdaysOnly = false
        self.switchWeekdaysOnly.isOn = false
        
        self.startDatePicker.date = Date()
        self.endDatePicker.date = (Calendar.current as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: 30, to: Date(), options: [])!
        self.validateAndSaveModel()
    }
    
    // Hides the keyboard if touch anywhere outside text box
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        
        if (indexPath.section == 4) {
            var url: URL? = nil;
            
            if (indexPath.row == 0) {
                url = URL(string: "https://www.bravelocation.com/countthedaysleft")!
            }
            else if (indexPath.row == 1) {
                url = URL(string: "http://github.com/bravelocation/daysleft")!
            }
            else if (indexPath.row == 2) {
                url = URL(string: "https://www.bravelocation.com/apps")!
            }
            
            if (url != nil) {
                let svc = SFSafariViewController(url: url!)
                svc.delegate = self
                self.present(svc, animated: true, completion: nil)
            }
        } else if (indexPath.section == 5) {
            if (indexPath.row == 1) {
                // Open the purchase controller
                let purchaseViewController = PurchaseViewController(nibName: "PurchaseViewController", bundle: nil)
                self.navigationController?.pushViewController(purchaseViewController, animated: true)
            }
        }
    }
    
    override func tableView( _ tableView : UITableView,  titleForHeaderInSection section: Int)->String
    {
        switch(section)
        {
        case 0:
            return "What are you counting down to?"
        case 1:
            return "Dates"
        case 2:
            return "Shortcuts"
        case 3:
            return "Settings"
        case 4:
            return "About"
        case 5:
            if (self.showAds()) {
                return "Ad (To help pay the bills)"
            } else {
                return "No Ads for you - thanks!"
            }
        default:
            return "Other"
        }
    }
    
    // Hides the keyboard if return is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    
    func validateAndSaveModel() {
        // Update the model
        let model = self.modelData()

        model.start = self.startDatePicker.date
        model.end = self.endDatePicker.date
        model.weekdaysOnly = self.switchWeekdaysOnly.isOn
        model.title = self.textTitle!.text!
        
        // Update the text fields
        self.textStart.text = String(format: "%@", self.dateFormatter.string(from: model.start))
        self.textEnd.text = String(format: "%@", self.dateFormatter.string(from: model.end))
        self.labelDaysLength.text = model.DaysLeftDescription(model.start)
        
        // Update the date restrictions too
        self.startDatePicker.maximumDate = model.end
        self.endDatePicker.minimumDate = model.start
        
        // Update the badge too
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.updateBadge()
        
        // Push any changes to watch
        model.pushAllSettingsToWatch()
    }
    
    func modelData() -> DaysLeftModel {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.model
    }
    
    func showAds() -> Bool {
        let model = self.modelData()
        return model.adsFree == false
    }
    
    // MARK: - SFSafariViewControllerDelegate methods
    func safariViewControllerDidFinish(_ controller: SFSafariViewController)
    {
        controller.dismiss(animated: true, completion: nil)
    }
}

