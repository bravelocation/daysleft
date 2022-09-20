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
    
    @ObservedObject var model: WatchDaysLeftViewModel
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .center) {
                Text(self.model.appSettings.watchDurationTitle(date: Date()))
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                Text(self.model.appSettings.title)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                ProgressControl(foregroundColor: Color("MainAppColor"),
                                backgroundColor: Color("LightAppColor"),
                                model: self.model,
                                lineWidth: 20.0,
                                frameSize: self.progressDimensions(geo.size))
                    .padding()
                Text(self.model.appSettings.currentPercentageLeft(date: Date())).font(.footnote)
            }.frame(width: geo.size.width, height: geo.size.height, alignment: .center)
        }
    }
    
    func progressDimensions(_ screenSize: CGSize) -> CGFloat {
        if (screenSize.width > screenSize.height) {
            return screenSize.height - 100
        } else {
            return screenSize.width - 100
        }
    }
}

struct WatchView_Previews: PreviewProvider {
    static var previews: some View {
        WatchView(model: WatchDaysLeftViewModel(dataManager: AppSettingsDataManager(dataProvider: InMemoryDataProvider())))
    }
}
