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
            
            Spacer()
            
            Text("\(self.model.displayValues.daysLeft)")
                .font(.system(size: 72, weight: .bold, design: .default))
            
            Text(self.model.displayValues.description)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
            
            CircularProgressView(progress: self.model.displayValues.percentageDone,
                                 lineWidth: 76.0)
            .padding([.top, .bottom], 16.0)
            .padding([.leading, .trailing], 64.0)
            .frame(maxWidth: 300.0, maxHeight: 300.0)
            
            HStack {
                Text(self.model.shortDateFormatted(date: self.model.displayValues.start))
                    .font(.footnote)
                Spacer()
                Text(self.model.shortDateFormatted(date: self.model.displayValues.end))
                    .font(.footnote)
            }
                .frame(maxWidth: 400.0)
                .padding([.leading, .trailing], 64.0)
            
            Text(self.model.displayValues.currentPercentageLeft)
                .font(.title)
                .padding([.top, .bottom], 16.0)
            
            Spacer()
        }
        .background(Color(uiColor: UIColor.systemBackground))
        .padding()
        .onAppear() {
            self.model.updateViewData()
        }
        .gesture(
            DragGesture(minimumDistance: 100.0)
                .onEnded { endedGesture in
                    // On swipe left, open the edit screen
                    if (endedGesture.location.x - endedGesture.startLocation.x) < 0 {
                        self.model.edit()
                    }
                }
            )
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
