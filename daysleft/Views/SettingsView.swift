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
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    Text("What are you counting down to?")
                        .font(.headline)
                    
                    TextField("Enter your title", text: self.$title)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: title) { newValue in
                            self.model.updateTitle(newValue)
                        }
                    
                    DatePicker(selection: $start, in: ...end, displayedComponents: .date) {
                        Text("Start counting from:")
                            .font(.subheadline)
                    }
                    .onChange(of: start) { newValue in
                        self.model.updateStartDate(newValue)
                    }
                    
                    DatePicker(selection: $end, in: start..., displayedComponents: .date) {
                        Text("to:")
                            .font(.subheadline)
                    }
                    .onChange(of: end) { newValue in
                        self.model.updateEndDate(newValue)
                    }
                    
                    Toggle("Weekdays only?", isOn: $weekdaysOnly)
                        .font(.subheadline)
                        .onChange(of: weekdaysOnly) { newValue in
                            self.model.updateWeekdaysOnly(newValue)
                        }
                }
            }
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
                     weekdaysOnly: dataManager.appSettings.weekdaysOnly)
    }
}
