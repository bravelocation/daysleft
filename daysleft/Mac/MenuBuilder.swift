//
//  MenuBuilder.swift
//  daysleft
//
//  Created by John Pollard on 28/07/2020.
//  Copyright © 2020 Brave Location Software. All rights reserved.
//

import UIKit

extension AppDelegate {
    /// Build the menu on the Mac and iPad
    /// - Parameter builder: Menu builder to use
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        
        guard builder.system == UIMenuSystem.main else { return }
        
        let editCommand = UIKeyCommand(title: NSLocalizedString("Edit Settings", comment: ""),
                                       action: #selector(editSettingsMenuCalled),
                                       input: "E",
                                       modifierFlags: .command)
        let shareCommand = UIKeyCommand(title: NSLocalizedString("Share", comment: ""),
                                        action: #selector(shareMenuCalled),
                                        input: "S",
                                        modifierFlags: [.command, .shift])
        
        let commandsMenu = UIMenu(title: "", options: .displayInline, children: [editCommand, shareCommand])
        builder.insertChild(commandsMenu, atStartOfMenu: .file)

    }
    
    /// Function called when Edit menu item is used
    /// - Parameter sender: Key sender
    @objc func editSettingsMenuCalled(_ sender: UIKeyCommand) {
        NotificationCenter.default.post(name: .editCommand, object: nil)
    }
    
    /// Function called when Share menu item is used
    /// - Parameter sender: Key sender
    @objc func shareMenuCalled(_ sender: UIKeyCommand) {
        NotificationCenter.default.post(name: .shareCommand, object: nil)
    }
}
