//
//  WatchView.swift
//  daysleft WatchKit Extension
//
//  Created by John Pollard on 13/11/2019.
//  Copyright © 2019 Brave Location Software. All rights reserved.
//

import Foundation
import SwiftUI

struct WatchView: View {
    
    @ObservedObject var model: DaysLeftViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            Text(self.model.appSettings.watchDurationTitle(date: Date()))
                .lineLimit(nil)
                .multilineTextAlignment(.center)
            
            Text(self.model.appSettings.title)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
            
            CircularProgressView(progress: self.model.percentageDone,
                                 lineWidth: 20.0)
            .padding([.top, .bottom], 16.0)
            
            Text(self.model.appSettings.currentPercentageLeft(date: Date())).font(.footnote)
        }
    }
}

struct WatchView_Previews: PreviewProvider {
    static var previews: some View {
        WatchView(model: DaysLeftViewModel(dataManager: AppSettingsDataManager(dataProvider: InMemoryDataProvider())))
    }
}
