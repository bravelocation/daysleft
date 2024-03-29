//
//  AppSettingsDataManager.swift
//  DaysLeft
//
//  Created by John Pollard on 20/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Foundation

/// Class that manages access to the data the app needs, either in local settings or via the iCloud key-value store
class AppSettingsDataManager {
    
    // MARK: - Properties
    
    /// Data provider
    private let dataProvider: DataProviderProtocol
    
    // MARK: - Initialisation functions
    
    /// Default initialiser for the class
    /// - Parameter dataProvider: Data provider that provides actula access to the data
    init(dataProvider: DataProviderProtocol = CloudKeyValueDataProvider.default) {

        self.dataProvider = dataProvider
        
        // Synchronise the data provider to try to get the latest data
        self.dataProvider.synchronise()
    }
    
    // MARK: - Settings values
    
    /// Main app settings
    var appSettings: AppSettings {
        return AppSettings(start: self.start,
                           end: self.end,
                           title: self.title,
                           weekdaysOnly: self.weekdaysOnly)
    }
    
    /// App control settings
    var appControlSettings: AppControlSettings {
        return AppControlSettings(showBadge: self.showBadge)
    }
    
    // MARK: - Data updating methods
    
    /// Update start date
    /// - Parameter date: New date
    func updateStartDate(_ date: Date) {
        self.start = date
    }
    
    /// Update end date
    /// - Parameter date: New date
    func updateEndDate(_ date: Date) {
        self.end = date
    }
    
    /// Update title
    /// - Parameter title: New title
    func updateTitle(_ title: String) {
        self.title = title
    }
    
    /// Update weekdays only
    /// - Parameter on: New weekdays only
    func updateWeekdaysOnly(_ on: Bool) {
        self.weekdaysOnly = on
    }
    
    /// Update the show badge value
    /// - Parameter value: Show badge i=on app icon
    func updateShowBadge(_ value: Bool) {
        self.showBadge = value
    }
    
    // MARK: - Property getters and setters
    
    /// Property to get and set the start date
    private var start: Date {
        get { return self.dataProvider.readObjectFromStore("start", defaultValue: Date().startOfDay) }
        set { self.dataProvider.writeObjectToStore(newValue.startOfDay, key: "start") }
    }
    
    /// Property to get and set the end date
    private var end: Date {
        get { return self.dataProvider.readObjectFromStore("end", defaultValue: Date.nextXmas()) }
        set { self.dataProvider.writeObjectToStore(newValue.startOfDay, key: "end") }
    }

    /// Property to get and set the title
    private var title: String {
        get { return self.dataProvider.readObjectFromStore("title", defaultValue: "Christmas") }
        set { self.dataProvider.writeObjectToStore(newValue, key: "title") }
    }

    /// Property to get and set the weekdays only flag
    private var weekdaysOnly: Bool {
        get { return self.dataProvider.readObjectFromStore("weekdaysOnly", defaultValue: false) }
        set { self.dataProvider.writeObjectToStore(newValue, key: "weekdaysOnly") }
    }
    
    /// Property to get and set the show badge flag
    private var showBadge: Bool {
        get { return self.dataProvider.readObjectFromStore("showBadge", defaultValue: false) }
        set { self.dataProvider.writeObjectToStore(newValue, key: "showBadge") }
    }
}
