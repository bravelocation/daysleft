//
//  IntentViewController.swift
//  DaysLeftIntentUI
//
//  Created by John Pollard on 21/09/2018.
//  Copyright © 2018 Brave Location Software. All rights reserved.
//

import IntentsUI

// As an example, this extension's Info.plist has been configured to handle interactions for INSendMessageIntent.
// You will want to replace this or add other intents as appropriate.
// The intents whose interactions you wish to handle must be declared in the extension's Info.plist.

// You can test this example integration by saying things to Siri like:
// "Send a message using <myApp>"

class IntentViewController: UIViewController, INUIHostedViewControlling {
    
    @IBOutlet weak var counterView: CounterView!    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let darkGreen = UIColor(red: 41/255, green: 63/255, blue: 1/255, alpha: 1.0)
        let lightGreen = UIColor(red: 203/255, green: 237/255, blue: 142/255, alpha: 1.0)
        let backgroundColor = UIColor.clear
        
        self.counterView.counterColor = lightGreen
        self.counterView.outlineColor = darkGreen
        self.counterView.backgroundColor = backgroundColor
        
        self.view.backgroundColor = backgroundColor
        self.titleLabel.textColor = UIColor(named: "IntentTextColor")
        self.percentLabel.textColor = UIColor(named: "IntentTextColor")
    }
        
    // MARK: - INUIHostedViewControlling
    func configureView(for parameters: Set<INParameter>, of interaction: INInteraction, interactiveBehavior: INUIInteractiveBehavior, context: INUIHostedViewContext, completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void) {
    
        guard interaction.intent is DaysLeftIntent else {
            completion(false, Set(), .zero)
            return
        }
        
        let now: Date = Date()
        let dataManager = AppSettingsDataManager()
        
        self.titleLabel.text = dataManager.fullDescription(now)
        
        let percentageDone: Float = (Float(dataManager.daysGone(now)) * 100.0) / Float(dataManager.daysLength)
        self.percentLabel.text = String(format: "%3.0f%% done", percentageDone)
        
        self.counterView.counter = dataManager.daysGone(now)
        self.counterView.maximumValue = dataManager.daysLength
        self.counterView.updateControl()
        
        completion(true, parameters, self.desiredSize)
    }
    
    var desiredSize: CGSize {
        return CGSize(width: self.extensionContext?.hostedViewMaximumAllowedSize.width ?? 320.00, height: 150.0)
    }
    
}
