//
//  InterfaceHostController.swift
//  daysleft WatchKit Extension
//
//  Created by John Pollard on 13/11/2019.
//  Copyright © 2019 Brave Location Software. All rights reserved.
//

import Foundation
import SwiftUI

class InterfaceHostController: WKHostingController<WatchView> {

    override var body: WatchView {
        return WatchView()
    }
}
