//
//  SettingsView.swift
//  DaysLeft
//
//  Created by John Pollard on 21/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import SwiftUI

/// Settings view
struct SettingsView: View {
    /// View model
    @ObservedObject var model: SettingsViewModel
    
    /// Start date
    @State var start: Date
    
    /// End date
    @State var end: Date
    
    /// Title
    @State var title: String
    
    /// Weekdays only?
    @State var weekdaysOnly: Bool
    
    /// Show the badge?
    @State var showBadge: Bool
    
    /// Body of view
    var body: some View {
        Form {
            Section {
                Text(LocalizedStringKey("What are you counting down to?"))
                    .font(.headline)
                    .foregroundColor(Color("SettingsIconTint"))
                    .listRowSeparator(.hidden)

                TextField(LocalizedStringKey("Enter your title"), text: self.$title)
                    .textFieldStyle(.roundedBorder)
                    .listRowSeparator(.hidden)
                    .onChange(of: title) { newValue in
                        self.model.updateTitle(newValue)
                    }

                DatePicker(selection: $start, in: ...end, displayedComponents: .date) {
                    Text(LocalizedStringKey("From"))
                }
                .listRowSeparator(.hidden)
                .onChange(of: start) { newValue in
                    self.model.updateStartDate(newValue)
                }

                DatePicker(selection: $end, in: start..., displayedComponents: .date) {
                    Text(LocalizedStringKey("To"))
                }
                .listRowSeparator(.hidden)
                .onChange(of: end) { newValue in
                    self.model.updateEndDate(newValue)
                }

                Toggle(LocalizedStringKey("Weekdays only?"), isOn: $weekdaysOnly)
                    .listRowSeparator(.hidden)
                    .tint(Color("SettingsIconTint"))
                    .onChange(of: weekdaysOnly) { newValue in
                        self.model.updateWeekdaysOnly(newValue)
                    }
            }
            
            Section {
                Text(LocalizedStringKey("Settings"))
                    .font(.headline)
                    .foregroundColor(Color("SettingsIconTint"))
                    .listRowSeparator(.hidden)

                Toggle(LocalizedStringKey("Show days left on app badge"), isOn: $showBadge)
                    .listRowSeparator(.hidden)
                    .tint(Color("SettingsIconTint"))
                    .onChange(of: showBadge) { newValue in
                        self.model.updateShowBadge(newValue)
                    }
            }
            
            Section(footer:
                        Text(self.model.versionNumber)
                            .accessibilityLabel("\(NSLocalizedString("App Version Number", comment: "")) \(self.model.versionNumber)")) {
                Text(LocalizedStringKey("About"))
                    .font(.headline)
                    .foregroundColor(Color("SettingsIconTint"))
                    .listRowSeparator(.hidden)
                
                SettingsLinkView(model: self.model,
                                 iconName: "lock.fill",
                                 title: "Privacy Policy",
                                 url: "https://bravelocation.com/privacy/daysleft")
                
                SettingsLinkView(model: self.model,
                                 iconName: "doc.richtext",
                                 title: "Read how the app was built",
                                 url: "https://writingontablets.com/categories#Count%20The%20Days%20Left")
                
                SettingsLinkView(model: self.model,
                                 iconName: "curlybraces",
                                 title: "See the code on GitHub",
                                 url: "http://github.com/bravelocation/daysleft")
                
                SettingsLinkView(model: self.model,
                                 iconName: "info.circle",
                                 title: "Bravelocation Software",
                                 url: "https://bravelocation.com")
            }
        }
    }
}

/// View to show link in settings
struct SettingsLinkView: View {
    /// View model
    @ObservedObject var model: SettingsViewModel
    
    /// System name of icon
    let iconName: String
    
    /// Title
    let title: String
    
    /// Url as string to link to
    let url: String
    
    /// Body of view
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(Color("SettingsIconTint"))
            Text(LocalizedStringKey(title))
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(Color(uiColor: UIColor.tertiaryLabel))
        }
        .onTapGesture {
            self.model.openExternalUrl(url)
        }
        .accessibilityElement(children: .combine)
        .accessibilityHint(LocalizedStringKey("Button"))
        .accessibilityLabel("\(NSLocalizedString("Open", comment: "")) \(NSLocalizedString(title, comment: ""))")
    }
}

/// Preview provider for SettingsView
struct SettingsView_Previews: PreviewProvider {
    static var dataManager = AppSettingsDataManager(dataProvider: InMemoryDataProvider())
    
    static var previews: some View {
        SettingsView(model: SettingsViewModel(dataManager: dataManager),
                     start: dataManager.appSettings.start,
                     end: dataManager.appSettings.end,
                     title: dataManager.appSettings.title,
                     weekdaysOnly: dataManager.appSettings.weekdaysOnly,
                     showBadge: dataManager.appControlSettings.showBadge)
    }
}
