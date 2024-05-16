//
//  MainView.swift
//  DaysLeft
//
//  Created by John Pollard on 21/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import SwiftUI

/// Main view of app
struct MainView: View {
    /// View model
    @ObservedObject var model: DaysLeftViewModel
    
    // Remote settings
    @ObservedObject var remoteConfig: RemoteConfigManager
    
    /// Body of view
    var body: some View {
        VStack(alignment: .center) {
            
            Spacer()
            
            if remoteConfig.showMessage {
                Text(remoteConfig.message ?? "")
            }
            
            Text("\(self.model.displayValues.daysLeft)")
                .font(.system(size: 72, weight: .bold, design: .default))
            
            Text(self.model.displayValues.description)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
            
            AnimatedCircularProgressView(progress: self.model.displayValues.percentageDone,
                                 lineWidth: 76.0)
            .padding([.top, .bottom], 16.0)
            .padding([.leading, .trailing], 64.0)
            .frame(maxWidth: 300.0, maxHeight: 300.0)
            
            HStack {
                Text(self.model.shortDateFormatted(date: self.model.displayValues.start))
                    .font(.footnote)
                    .accessibilityLabel("\(NSLocalizedString("From", comment: "")) \(self.model.accessibilityDateFormatted(date: self.model.displayValues.start))")
                Spacer()
                Text(self.model.shortDateFormatted(date: self.model.displayValues.end))
                    .font(.footnote)
                    .accessibilityLabel("\(NSLocalizedString("To", comment: "")) \(self.model.accessibilityDateFormatted(date: self.model.displayValues.end))")
            }
                .frame(maxWidth: 400.0)
                .padding([.leading, .trailing], 64.0)
            
            AnimatedPercentageDone(percentageDone: self.model.displayValues.percentageDone)
                .frame(height: 50.0)
                .font(.title)
                .padding([.top, .bottom], 16.0)
            
            Spacer()
        }
        .frame(maxWidth: 800)
        .background(Color(uiColor: UIColor.systemBackground))
        .padding()
        .onAppear {
            self.model.updateViewData()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
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
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(
                    action: {
                        self.model.edit()
                    },
                    label: {
                        Text(LocalizedStringKey("Toolbar Edit"))
                            .foregroundColor(Color.white)
                    })
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityIdentifier("editButton")
            }
            
            ToolbarItem(placement: self.shareButtonPlacement) {
                Button(
                    action: {
                        self.model.share()
                    },
                    label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(Color.white)
                    })
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityIdentifier("shareButton")
            }
            
            ToolbarItem(placement: .principal) {
                Text(LocalizedStringKey("App Title"))
                    .foregroundColor(Color.white)
            }
        }
    }
    
    private var shareButtonPlacement: ToolbarItemPlacement {
//        #if targetEnvironment(macCatalyst)
//        if #available(macCatalyst 16.0, *) {
//            return .secondaryAction
//        }
//        #endif
        
        return .topBarLeading
    }
}

/// Preview provider for MainView
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(model: DaysLeftViewModel(dataManager: AppSettingsDataManager(dataProvider: InMemoryDataProvider.shared)),
                 remoteConfig: RemoteConfigManager.shared)
    }
}
