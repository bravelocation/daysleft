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
import Intents
import IntentsUI

class SettingsViewController: UITableViewController, UITextFieldDelegate, SFSafariViewControllerDelegate, INUIAddVoiceShortcutViewControllerDelegate {
    
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
    @IBOutlet weak var addToSiriCell: UITableViewCell!
    @IBOutlet weak var gitHubCell: UITableViewCell!
    @IBOutlet weak var appMadeCell: UITableViewCell!
    @IBOutlet weak var moreAppsCell: UITableViewCell!
    @IBOutlet weak var privacyCell: UITableViewCell!
    
    var dateFormatter: DateFormatter = DateFormatter()
    let startDatePicker: UIDatePicker = UIDatePicker()
    let endDatePicker: UIDatePicker = UIDatePicker()
    
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
        self.labelDaysLength.text = model.daysLeftDescription(model.start)
        
        // Setup the date pickers as editors for text fields
        self.startDatePicker.date = model.start
        self.startDatePicker.maximumDate = model.end
        self.startDatePicker.datePickerMode = UIDatePicker.Mode.date
        self.startDatePicker.addTarget(self, action: #selector(SettingsViewController.dateChanged(_:)), for: UIControl.Event.valueChanged)
        self.textStart.inputView = self.startDatePicker
        
        self.endDatePicker.date = model.end
        self.endDatePicker.minimumDate = model.start
        self.endDatePicker.datePickerMode = UIDatePicker.Mode.date
        self.endDatePicker.addTarget(self, action: #selector(SettingsViewController.dateChanged(_:)), for: UIControl.Event.valueChanged)
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
        
        // Setup Add to Siri button
        if #available(iOS 12.0, *) {
            var buttonStyle: INUIAddVoiceShortcutButtonStyle = .whiteOutline
            
            if #available(iOS 13.0, *) {
                buttonStyle = .automaticOutline
            }
            
            let button = INUIAddVoiceShortcutButton(style: buttonStyle)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            self.addToSiriCell.addSubview(button)
            button.addTarget(self, action: #selector(addToSiri(_:)), for: .touchUpInside)
            
            self.addToSiriCell.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
            self.addToSiriCell.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        } else {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false

            label.text = "Add to Siri only available on iOS 12+"
            label.textColor = UIColor.lightGray
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            
            self.addToSiriCell.addSubview(label)
            self.addToSiriCell.leftAnchor.constraint(equalTo: label.leftAnchor, constant: 8.0).isActive = true
            self.addToSiriCell.rightAnchor.constraint(equalTo: label.rightAnchor, constant: 8.0).isActive = true
            self.addToSiriCell.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show the ads if not hidden
        if (self.showAds()) {
            let request = GADRequest()
            
            #if targetEnvironment(simulator)
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
        
        // Set the about cell logos
        self.setCellImage(imageName: "Privacy", color: UIColor(named: "SettingsIconTint"), cell: self.privacyCell)
        self.setCellImage(imageName: "GitHubLogo", color: UIColor(named: "SettingsIconTint"), cell: self.gitHubCell)
        self.setCellImage(imageName: "ReadHow", color: UIColor(named: "SettingsIconTint"), cell: self.appMadeCell)
        self.setCellImage(imageName: "BraveLocation", color: UIColor(named: "BraveLocationColor"), cell: self.moreAppsCell)
    }
    
    private func setCellImage(imageName: String, color: UIColor?, cell: UITableViewCell) {
        if let assetImage = UIImage(named: imageName), let imageView = cell.imageView {
            let tintableImage = assetImage.withRenderingMode(.alwaysTemplate)
            imageView.image = tintableImage
            imageView.tintColor = color
        }
    }

    @IBAction func textTitleChanged(_ sender: AnyObject) {
        self.validateAndSaveModel()
    }
    
    @objc
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
    
    // Hides the keyboard if touch anywhere outside text box
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        
        if (indexPath.section == 4) {
            var url: URL? = nil
            
            if (indexPath.row == 0) {
                url = URL(string: "https://bravelocation.com/privacy/daysleft")!
            } else if (indexPath.row == 1) {
                url = URL(string: "https://bravelocation.com/countthedaysleft")!
            } else if (indexPath.row == 2) {
                url = URL(string: "http://github.com/bravelocation/daysleft")!
            } else if (indexPath.row == 3) {
                url = URL(string: "https://bravelocation.com/apps")!
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        switch(section) {
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
        self.view.endEditing(true)
        return false
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
        self.labelDaysLength.text = model.daysLeftDescription(model.start)
        
        // Update the date restrictions too
        self.startDatePicker.maximumDate = model.end
        self.endDatePicker.minimumDate = model.start
        
        // Update the badge too
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.updateBadge()
        
        // Push any changes to watch
        model.pushAllSettingsToWatch()
    }
    
    func modelData() -> AppDaysLeftModel {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.model
    }
    
    func showAds() -> Bool {
        let model = self.modelData()
        return model.adsFree == false
    }
    
    // MARK: - SFSafariViewControllerDelegate methods
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Siri handling
    @objc
    func addToSiri(_ sender: Any) {
        if #available(iOS 12.0, *) {
            let intent = DaysLeftIntent()
            intent.suggestedInvocationPhrase = "How Many Days Left"
            
            if let shortcut = INShortcut(intent: intent) {
                let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
                viewController.modalPresentationStyle = .formSheet
                viewController.delegate = self
                self.present(viewController, animated: true, completion: nil)
            }
        } else {
            // Show an alert
            let alert = UIAlertController(title: "Not Supported", message: "Add to Siri is only supported on iOS 12 and above", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(defaultAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - INUIAddVoiceShortcutViewControllerDelegate
    @available(iOS 12.0, *)
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        print("Added shortcut")
        controller.dismiss(animated: true, completion: nil)
    }
    
    @available(iOS 12.0, *)
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        print("Cancelled shortcut")
        controller.dismiss(animated: true, completion: nil)
    }
}
