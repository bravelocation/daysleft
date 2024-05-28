//
//  WatchView.swift
//  daysleft WatchKit Extension
//
//  Created by John Pollard on 13/11/2019.
//  Copyright © 2019 Brave Location Software. All rights reserved.
//

import Foundation
import SwiftUI

/// Main watch view
struct WatchView: View {
    
    /// View model
    @ObservedObject var model: DaysLeftViewModel
    
    /// View body
    var body: some View {
        VStack(alignment: .center) {
            Text(self.model.displayValues.watchDurationTitle)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
            
            Text(self.model.displayValues.title)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
            
            AnimatedCircularProgressView(model: self.model, lineWidth: 20.0)
            .padding([.top, .bottom], 16.0)
            
            AnimatedPercentageDone(percentageDone: self.model.displayValues.percentageDone)
                .frame(height: 30.0)
                .font(.footnote)
        }
    }
}

/// Preview provider for WatchView
struct WatchView_Previews: PreviewProvider {
    static var previews: some View {
        WatchView(model: DaysLeftViewModel(dataManager: AppSettingsDataManager(dataProvider: InMemoryDataProvider.shared)))
    }
}
