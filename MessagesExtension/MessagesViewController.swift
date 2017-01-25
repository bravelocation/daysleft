//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by John Pollard on 25/09/2016.
//  Copyright © 2016 Brave Location Software. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    
    
    @IBOutlet weak var imageProgress: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    //@IBOutlet weak var labelPercentDone: UILabel!
    @IBOutlet weak var buttonSendMessage: UIButton!
    
    override func viewDidLoad() {
        print("In viewDidload...")
        super.viewDidLoad()
             
        // Set border on button
        self.buttonSendMessage!.layer.borderColor = UIColor(red: 44.0/255.0, green: 94.0/255.0, blue: 22.0/255.0, alpha: 1.0).cgColor
        self.buttonSendMessage!.layer.borderWidth = 1.0
        self.buttonSendMessage!.layer.cornerRadius = 5.0
        
        self.updateViewData()
    }
    
    @IBAction func sendMessageTouchUp(_ sender: AnyObject) {
        if let conversation = self.activeConversation {
            let layout = MSMessageTemplateLayout()
            
            let now: Date = Date()
            let model: DaysLeftModel = DaysLeftModel()
            
            layout.caption = model.FullDescription(now)
            
            let percentageDone: Float = (Float(model.DaysGone(now)) * 100.0) / Float(model.DaysLength)
            let intPercentageDone: Int = Int(percentageDone)            
            let imageName = String(format: "progress%d", intPercentageDone)
            layout.image = UIImage(named:imageName)
            
            let message = MSMessage()
            message.layout = layout
            
            conversation.insert(message, completionHandler: { (error: Error?) in
                print(error ?? "")
            })
        }
    }
    
    fileprivate func updateViewData() {
        let now: Date = Date()
        let model: DaysLeftModel = DaysLeftModel()
        
        self.labelTitle.text = model.FullDescription(now)
        
        let percentageDone: Float = (Float(model.DaysGone(now)) * 100.0) / Float(model.DaysLength)
        //self.labelPercentDone.text = String(format:"%3.0f%% done", percentageDone)
        
        // Update image
        let intPercentageDone: Int = Int(percentageDone)
        let imageName = String(format: "progress%d", intPercentageDone)
        self.imageProgress!.image = UIImage(named:imageName)
        
        NSLog("View updated!")
    }
}
