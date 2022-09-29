//
//  UIDevice.swift
//  DaysLeft
//
//  Created by John Pollard on 29/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import UIKit

extension UIDevice {

    /// Checks if the current device that runs the app is xCode's simulator
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }
}
