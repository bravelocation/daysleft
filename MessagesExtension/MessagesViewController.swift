//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by John Pollard on 25/09/2016.
//  Copyright © 2016 Brave Location Software. All rights reserved.
//

import UIKit
import Messages
import daysleftlibrary

class MessagesViewController: MSMessagesAppViewController {
    
    
    @IBOutlet weak var imageProgress: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelPercentDone: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateViewData()
    }
    
    @IBAction func sendMessageTouchUp(_ sender: AnyObject) {
        if let conversation = self.activeConversation {
            let layout = MSMessageTemplateLayout()
            
            let now: NSDate = NSDate()
            let model: DaysLeftModel = DaysLeftModel()
            
            layout.caption = model.FullDescription(now)
            
            let percentageDone: Float = (Float(model.DaysGone(now)) * 100.0) / Float(model.DaysLength)
            let intPercentageDone: Int = Int(percentageDone)            
            let imageName = String(format: "progress%d", intPercentageDone)
            layout.image = UIImage(imageLiteral:imageName)
            
            let message = MSMessage()
            message.layout = layout
            
            conversation.insertMessage(message, completionHandler: { (error: NSError?) in
                print(error)
            })
        }
    }
    
    private func updateViewData() {
        let now: NSDate = NSDate()
        let model: DaysLeftModel = DaysLeftModel()
        
        self.labelTitle.text = model.FullDescription(now)
        
        let percentageDone: Float = (Float(model.DaysGone(now)) * 100.0) / Float(model.DaysLength)
        self.labelPercentDone.text = String(format:"%3.0f%% done", percentageDone)
        
        // Update image
        let intPercentageDone: Int = Int(percentageDone)
        let imageName = String(format: "progress%d", intPercentageDone)
        self.imageProgress!.image = UIImage(imageLiteral:imageName)
        
        NSLog("View updated")
    }

    
    // MARK: - Conversation Handling
}
