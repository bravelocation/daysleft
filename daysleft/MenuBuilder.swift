//
//  MenuBuilder.swift
//  daysleft
//
//  Created by John Pollard on 28/07/2020.
//  Copyright © 2020 Brave Location Software. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let menuCommand = Notification.Name("com.bravelocation.daysleft.menu")
}

@available(iOS 13.0, *)
extension AppDelegate {
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        
        guard builder.system == UIMenuSystem.main else { return }
        
        let editCommand = UIKeyCommand(title: "Edit Settings", action: #selector(editSettingsMenuCalled), input: "E", modifierFlags: .command)
        let shareCommand = UIKeyCommand(title: "Share", action: #selector(shareMenuCalled), input: "S", modifierFlags: [.command, .shift])
        
        let commandsMenu = UIMenu(title: "", options: .displayInline, children: [editCommand, shareCommand])
        builder.insertChild(commandsMenu, atStartOfMenu: .file)

    }
    
    @objc
    func editSettingsMenuCalled(_ sender: UIKeyCommand) {
        self.sendMenuNotification(sender)
    }
    
    @objc
    func shareMenuCalled(_ sender: UIKeyCommand) {
        self.sendMenuNotification(sender)
    }
    
    func sendMenuNotification(_ sender: UIKeyCommand) {
       NotificationCenter.default.post(name: .menuCommand, object: sender)
    }
}
