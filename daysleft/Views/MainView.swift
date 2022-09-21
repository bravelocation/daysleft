//
//  MainView.swift
//  DaysLeft
//
//  Created by John Pollard on 21/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import SwiftUI

struct MainView: View {
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
        }.padding()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(model: DaysLeftViewModel(dataManager: AppSettingsDataManager(dataProvider: InMemoryDataProvider())))
    }
}
