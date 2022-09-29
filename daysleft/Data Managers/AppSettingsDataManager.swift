//
//  AppSettingsDataManager.swift
//  DaysLeft
//
//  Created by John Pollard on 20/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Foundation

extension Notification.Name {
    /// Name of the notification sent when app settings are updated
    static let AppSettingsUpdated = Notification.Name(rawValue: "UpdateSettingsNotification")
}

/// Class that manages access to the data the app needs, either in local settings or via the iCloud key-value store
class AppSettingsDataManager {
    
    // MARK: - Properties
    
    /// Data provider
    private let dataProvider: DataProviderProtocol
    
    /// Is this the current first run (integer not boolean for legacy reasons)
    let currentFirstRun: Int = 1
    
    // MARK: - Initialisation functions
    
    /// Default initialiser for the class
    /// - Parameter dataProvider: Data provider that provides actula access to the data
    init(dataProvider: DataProviderProtocol = CloudKeyValueDataProvider.default) {

        self.dataProvider = dataProvider
        
        // Setup some of the settings if first run of the app
        if (self.firstRun < self.currentFirstRun) {
            // If it is first run, initialise the model data to Christmas
            self.start = Date().startOfDay
            self.end = Date.nextXmas()
            self.title = "Christmas"
            self.weekdaysOnly = false
            
            // Save the first run once working
            self.firstRun = self.currentFirstRun
        }
        
        // Synchronise the data provider to try to get the latest data
        self.dataProvider.synchronise()
    }
    
    // MARK: - Settings values
    
    /// Main app settings
    var appSettings: AppSettings {
        get {
            return AppSettings(start: self.start,
                               end: self.end,
                               title: self.title,
                               weekdaysOnly: self.weekdaysOnly)
        }
    }
    
    /// App control settings
    var appControlSettings: AppControlSettings {
        get {
            return AppControlSettings(firstRun: self.firstRun,
                                      showBadge: self.showBadge)
        }
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
        get { return self.dataProvider.readObjectFromStore("start") as! Date }
        set { self.dataProvider.writeObjectToStore(newValue.startOfDay as AnyObject, key: "start") }
    }
    
    /// Property to get and set the end date
    private var end: Date {
        get { return self.dataProvider.readObjectFromStore("end") as! Date }
        set { self.dataProvider.writeObjectToStore(newValue.startOfDay, key: "end") }
    }

    /// Property to get and set the title
    private var title: String {
        get { return self.dataProvider.readObjectFromStore("title") as! String }
        set { self.dataProvider.writeObjectToStore(newValue, key: "title") }
    }

    /// Property to get and set the weekdays only flag
    private var weekdaysOnly: Bool {
        get { return self.dataProvider.readObjectFromStore("weekdaysOnly") as! Bool }
        set { self.dataProvider.writeObjectToStore(newValue, key: "weekdaysOnly") }
    }
    
    /// Property to get and set the firstRun value
    private var firstRun: Int {
        get { return self.dataProvider.readObjectFromStore("firstRun") as! Int }
        set { self.dataProvider.writeObjectToStore(newValue, key: "firstRun") }
    }
    
    /// Property to get and set the show badge flag
    private var showBadge: Bool {
        get { return self.dataProvider.readObjectFromStore("showBadge") as! Bool }
        set { self.dataProvider.writeObjectToStore(newValue, key: "showBadge") }
    }
}
