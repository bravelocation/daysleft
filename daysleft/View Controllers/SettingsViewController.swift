//
//  SettingsViewController.swift
//  daysleft
//
//  Created by John Pollard on 17/02/2015.
//  Copyright (c) 2015 Brave Location Software. All rights reserved.
//

import UIKit
import SafariServices
import Intents
import IntentsUI

class SettingsViewController: UITableViewController, UITextFieldDelegate, SFSafariViewControllerDelegate, INUIAddVoiceShortcutViewControllerDelegate {
    
    @IBOutlet weak var textTitle: UITextField!
    @IBOutlet weak var switchWeekdaysOnly: UISwitch!
    @IBOutlet weak var labelDaysLength: UILabel!
    @IBOutlet weak var labelVersion: UILabel!
    @IBOutlet weak var switchShowBadge: UISwitch!
    @IBOutlet weak var becomeASupporterCell: UITableViewCell!
    @IBOutlet weak var addToSiriCell: UITableViewCell!
    @IBOutlet weak var gitHubCell: UITableViewCell!
    @IBOutlet weak var appMadeCell: UITableViewCell!
    @IBOutlet weak var moreAppsCell: UITableViewCell!
    @IBOutlet weak var privacyCell: UITableViewCell!

    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    @IBOutlet weak var startDayOfWeek: UILabel!
    @IBOutlet weak var endDayOfWeek: UILabel!

    var dateFormatter: DateFormatter = DateFormatter()
    
    /// App data manager
    let dataManager = AppSettingsDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appSettings = self.dataManager.appSettings

        self.textTitle.text = appSettings.title
        self.switchWeekdaysOnly.isOn = appSettings.weekdaysOnly
        self.switchShowBadge.isOn = self.dataManager.appControlSettings.showBadge
        
        // Setup date formatter
        self.dateFormatter.dateFormat = "EEE d MMM YYYY"
        
        self.labelDaysLength.text = appSettings.daysLeftDescription(appSettings.start)
        
        // Setup the date pickers
        self.startDatePicker.date = appSettings.start
        self.startDatePicker.maximumDate = appSettings.end
        self.startDatePicker.datePickerMode = UIDatePicker.Mode.date
        self.startDatePicker.addTarget(self, action: #selector(SettingsViewController.dateChanged(_:)), for: UIControl.Event.valueChanged)
        self.startDayOfWeek.text = self.startDatePicker.date.weekdayName
        
        self.endDatePicker.date = appSettings.end
        self.endDatePicker.minimumDate = appSettings.start
        self.endDatePicker.datePickerMode = UIDatePicker.Mode.date
        self.endDatePicker.addTarget(self, action: #selector(SettingsViewController.dateChanged(_:)), for: UIControl.Event.valueChanged)
        self.endDayOfWeek.text = self.endDatePicker.date.weekdayName

        // Set up the delegate of text field for handling return below
        self.textTitle.delegate = self
        
        // Add version number
        let infoDictionary = Bundle.main
        let version = infoDictionary.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build = infoDictionary.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        self.labelVersion.text = String(format: "v%@.%@", version, build)
        
        // Setup Add to Siri button
        let buttonStyle: INUIAddVoiceShortcutButtonStyle = .automaticOutline
        let button = INUIAddVoiceShortcutButton(style: buttonStyle)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        self.addToSiriCell.addSubview(button)
        button.addTarget(self, action: #selector(addToSiri(_:)), for: .touchUpInside)
        
        self.addToSiriCell.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
        self.addToSiriCell.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show the become a supporter cell if not hidden
        if (self.isNotASupporter()) {
            self.becomeASupporterCell.isHidden = false
        } else {
            self.becomeASupporterCell.isHidden = true
        }
        
        // Set the about cell logos
        self.setCellImage(imageName: "Privacy", systemName: "lock.fill", color: UIColor(named: "SettingsIconTint"), cell: self.privacyCell)
        self.setCellImage(imageName: "ReadHow", systemName: "doc.richtext", color: UIColor(named: "SettingsIconTint"), cell: self.appMadeCell)
        self.setCellImage(imageName: "GitHubLogo", systemName: "chevron.left.slash.chevron.right", color: UIColor(named: "SettingsIconTint"), cell: self.gitHubCell)
        self.setCellImage(imageName: "BraveLocation", systemName: "app.badge", color: UIColor(named: "SettingsIconTint"), cell: self.moreAppsCell)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AnalyticsManager.shared.logScreenView(screenName: "Settings Screen")
    }
    
    private func setCellImage(imageName: String, systemName: String?, color: UIColor?, cell: UITableViewCell) {
        var assetImage = UIImage(named: imageName)
        if let name = systemName {
            assetImage = UIImage(systemName: name)
        }
        
        if let image = assetImage, let imageView = cell.imageView {
            let tintableImage = image.withRenderingMode(.alwaysTemplate)
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
        self.dataManager.updateShowBadge(switchShowBadge.isOn)
        
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
            if (indexPath.row == 0) {
                // Open the purchase controller if we can become a support
                if (self.isNotASupporter()) {
                    let purchaseViewController = PurchaseViewController(nibName: "PurchaseViewController", bundle: nil)
                    self.navigationController?.pushViewController(purchaseViewController, animated: true)
                }
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
            if (self.isNotASupporter()) {
                return "Become a supporter"
            } else {
                return "Thanks for being a supporter!"
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
        self.dataManager.updateAppSettings(start: self.startDatePicker.date,
                                end: self.endDatePicker.date,
                                title: self.textTitle!.text!,
                                weekdaysOnly: self.switchWeekdaysOnly.isOn)
        
        // Update the text fields
        let updatedAddSettings = self.dataManager.appSettings
        
        self.labelDaysLength.text = updatedAddSettings.daysLeftDescription(updatedAddSettings.start)
        self.startDayOfWeek.text = updatedAddSettings.start.weekdayName
        self.endDayOfWeek.text = updatedAddSettings.end.weekdayName
        
        // Update the date restrictions too
        self.startDatePicker.maximumDate = updatedAddSettings.end
        self.endDatePicker.minimumDate = updatedAddSettings.start
        
        // Update the badge and widgets too
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.updateBadge()
        appDelegate.updateWidgets()
    }
    
    func isNotASupporter() -> Bool {
        return self.dataManager.appControlSettings.isASupporter == false
    }
    
    // MARK: - SFSafariViewControllerDelegate methods
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Siri handling
    @objc
    func addToSiri(_ sender: Any) {
        let intent = DaysLeftIntent()
        intent.suggestedInvocationPhrase = "How Many Days Left"
        
        if let shortcut = INShortcut(intent: intent) {
            let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
            viewController.modalPresentationStyle = .formSheet
            viewController.delegate = self
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    // MARK: - INUIAddVoiceShortcutViewControllerDelegate
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        print("Added shortcut")
        controller.dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        print("Cancelled shortcut")
        controller.dismiss(animated: true, completion: nil)
    }
}

extension Date {
    var weekdayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        
        return formatter.string(from: self)
    }
}
