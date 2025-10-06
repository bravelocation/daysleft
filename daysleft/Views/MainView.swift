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
    
    /// Body of view
    var body: some View {
        let progressHeightFraction = 2.5
        
        GeometryReader { geo in
            ZStack(alignment: .center) {
                VStack(alignment: .center) {
                    Spacer()
                    
                    Text("\(self.model.displayValues.daysLeft)")
                        .font(.system(size: 72, weight: .bold, design: .default))
                    
                    Text(self.model.displayValues.description)
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                    
                    AnimatedCircularProgressView(model: self.model)
                        .padding([.top, .bottom], 16.0)
                        .padding([.leading, .trailing], 64.0)
                        .frame(maxWidth: geo.size.height / progressHeightFraction, maxHeight: geo.size.height / progressHeightFraction)
                        .id(geo.size.height) // Force a redraw when the screen height changes
                    
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
            }
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
                            
                            Task {
                                await EditIntroTip.settingsOpenedCount.donate()
                            }
                        },
                        label: {
                            Text(LocalizedStringKey("Toolbar Edit"))
                                .foregroundColor(Color(self.toolbarColor))
                        })
                    .popoverTip(
                        EditIntroTip()
                    )
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityIdentifier("editButton")
                    .fixedSize(horizontal: true, vertical: false)
                }
                
                ToolbarItem(placement: self.shareButtonPlacement) {
                    Button(
                        action: {
                            self.model.share()
                        },
                        label: {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(Color(self.toolbarColor))
                        })
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityIdentifier("shareButton")
                }
                
                ToolbarItem(placement: .principal) {
                    Text(LocalizedStringKey("App Title"))
                        .foregroundColor(Color(self.toolbarColor))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var shareButtonPlacement: ToolbarItemPlacement {
        return .topBarLeading
    }
    
    private var toolbarColor: UIColor {
        // Customise the nav bar
        let blueColor = UIColor(named: "SettingsIconTint") ?? UIColor.blue
        
        var foregroundColor = UIColor.white
        
        if #available(iOS 26.0, *) {
            foregroundColor = blueColor
        }
        
        return foregroundColor
    }
}

/// Preview provider for MainView
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(model: DaysLeftViewModel(dataManager: AppSettingsDataManager(dataProvider: InMemoryDataProvider.shared)))
    }
}
