//
//  SettingsView.swift
//  DaysLeft
//
//  Created by John Pollard on 21/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var model: SettingsViewModel
    
    @State var start: Date
    @State var end: Date
    @State var title: String
    @State var weekdaysOnly: Bool
    @State var showBadge: Bool
    
    var body: some View {
        Form {
            Section {
                Text("What are you counting down to?")
                    .font(.headline)
                    .foregroundColor(Color("SettingsIconTint"))
                    .listRowSeparator(.hidden)

                TextField("Enter your title", text: self.$title)
                    .textFieldStyle(.roundedBorder)
                    .listRowSeparator(.hidden)
                    .onChange(of: title) { newValue in
                        self.model.updateTitle(newValue)
                    }

                DatePicker(selection: $start, in: ...end, displayedComponents: .date) {
                    Text("From")
                }
                .listRowSeparator(.hidden)
                .onChange(of: start) { newValue in
                    self.model.updateStartDate(newValue)
                }

                DatePicker(selection: $end, in: start..., displayedComponents: .date) {
                    Text("To")
                }
                .listRowSeparator(.hidden)
                .onChange(of: end) { newValue in
                    self.model.updateEndDate(newValue)
                }

                Toggle("Weekdays only?", isOn: $weekdaysOnly)
                    .listRowSeparator(.hidden)
                    .tint(Color("SettingsIconTint"))
                    .onChange(of: weekdaysOnly) { newValue in
                        self.model.updateWeekdaysOnly(newValue)
                    }
            }
            
            Section {
                Text("Settings")
                    .font(.headline)
                    .foregroundColor(Color("SettingsIconTint"))
                    .listRowSeparator(.hidden)

                Toggle("Show days left on app badge", isOn: $showBadge)
                    .listRowSeparator(.hidden)
                    .tint(Color("SettingsIconTint"))
                    .onChange(of: showBadge) { newValue in
                        self.model.updateShowBadge(newValue)
                    }
            }
            
            Section(footer: Text(self.model.versionNumber)) {
                Text("About")
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
                                 url: "https://bravelocation.com/countthedaysleft")
                
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

struct SettingsLinkView: View {
    @ObservedObject var model: SettingsViewModel
    let iconName: String
    let title: String
    let url: String
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(Color("SettingsIconTint"))
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(Color(uiColor: UIColor.tertiaryLabel))
        }.onTapGesture {
            self.model.openExternalUrl(url)
        }
    }
}

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
