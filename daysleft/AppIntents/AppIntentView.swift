//
//  AppIntentView.swift
//  DaysLeft
//
//  Created by John Pollard on 22/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import SwiftUI

@available(iOS 16, watchOS 9.0, *)
struct AppIntentView: View {
    let currentDate: Date
    let appSettings: AppSettings
    
    var body: some View {
        VStack(alignment: .center) {
            Text(self.appSettings.fullTitle(date: currentDate))
                .lineLimit(2)
                .allowsTightening(true)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            CircularProgressView(progress: self.appSettings.percentageDone(date: self.currentDate),
                                 lineWidth: 12.0)
            .padding([.top, .bottom], 16.0)
            
            Text(self.appSettings.currentPercentageLeft(date: currentDate))
                .font(.footnote)
        }
        .padding()
    }
}

@available(iOS 16, watchOS 9.0, *)
struct AppIntentView_Previews: PreviewProvider {
    static var appSettings = AppSettingsDataManager(dataProvider: InMemoryDataProvider()).appSettings
    
    static var previews: some View {
        AppIntentView(currentDate: Date(), appSettings: appSettings)
    }
}
