//
//  MenuBuilder.swift
//  daysleft
//
//  Created by John Pollard on 28/07/2020.
//  Copyright © 2020 Brave Location Software. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let editCommand = Notification.Name("com.bravelocation.daysleft.edit")
    static let shareCommand = Notification.Name("com.bravelocation.daysleft.share")
}

extension AppDelegate {
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        
        guard builder.system == UIMenuSystem.main else { return }
        
        let editCommand = UIKeyCommand(title: NSLocalizedString("Edit Settings", comment: "Name of the edit settings menu command"),
                                       action: #selector(editSettingsMenuCalled),
                                       input: "E",
                                       modifierFlags: .command)
        let shareCommand = UIKeyCommand(title: NSLocalizedString("Share", comment: "Name of the share menu command"),
                                        action: #selector(shareMenuCalled),
                                        input: "S",
                                        modifierFlags: [.command, .shift])
        
        let commandsMenu = UIMenu(title: "", options: .displayInline, children: [editCommand, shareCommand])
        builder.insertChild(commandsMenu, atStartOfMenu: .file)

    }
    
    @objc
    func editSettingsMenuCalled(_ sender: UIKeyCommand) {
        NotificationCenter.default.post(name: .editCommand, object: nil)
    }
    
    @objc
    func shareMenuCalled(_ sender: UIKeyCommand) {
        NotificationCenter.default.post(name: .shareCommand, object: nil)
    }
}
