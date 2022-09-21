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
    
    let now = Date()
    
    var body: some View {
        VStack(alignment: .center) {
            
            Text("\(self.model.appSettings.daysLeft(now))")
                .font(.largeTitle)
            
            Text(self.model.appSettings.description(now))
                .lineLimit(nil)
                .multilineTextAlignment(.center)
            
            CircularProgressView(progress: self.model.percentageDone,
                                 lineWidth: 76.0)
            .padding([.top, .bottom], 64.0)
            .padding([.leading, .trailing], 96.0)
            
            HStack {
                Text(self.model.appSettings.shortDateFormatted(date: self.model.appSettings.start))
                    .font(.footnote)
                Spacer()
                Text(self.model.appSettings.shortDateFormatted(date: self.model.appSettings.end))
                    .font(.footnote)
            }
                .padding([.leading, .trailing], 64.0)
            
            Text(self.model.appSettings.currentPercentageLeft(date: now))
                .font(.title)
                .padding()
        }
        .padding()
        .onAppear() {
            self.model.updateViewData()
        }
        .navigationBarTitle(Text("Count The Days Left"))
        .navigationBarItems(leading:
                                Button(
                                    action: {
                                        self.model.share()
                                    },
                                    label: {
                                        Image(systemName: "square.and.arrow.up")
                                            .foregroundColor(Color.white)
                                    })
                                    .buttonStyle(PlainButtonStyle()),
                            trailing: Button(
                                action: {
                                    self.model.edit()
                                },
                                label: {
                                    Text("Edit")
                                        .foregroundColor(Color.white)
                                })
                                .buttonStyle(PlainButtonStyle())
                            
        )
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(model: DaysLeftViewModel(dataManager: AppSettingsDataManager(dataProvider: InMemoryDataProvider())))
    }
}
