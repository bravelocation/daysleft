//
//  MainViewHostingController.swift
//  DaysLeft
//
//  Created by John Pollard on 21/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Foundation
import SwiftUI

class MainViewHostingController<Content: View>: UIHostingController<Content> {

    let viewModel: DaysLeftViewModel = DaysLeftViewModel(dataManager: AppSettingsDataManager())

    init() {
        let rootView = MainView(model: self.viewModel)

        super.init(rootView: AnyView(rootView) as! Content)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
