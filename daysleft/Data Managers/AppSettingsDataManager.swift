//
//  AppSettingsDataManager.swift
//  DaysLeft
//
//  Created by John Pollard on 20/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Foundation

class AppSettingsDataManager {
    
    // MARK: - Properties

    /// Notification name for when the data has been updated
    public static let UpdateSettingsNotification = "UpdateSettingsNotification"
    
    /// Data provider
    private let dataProvider: DataProviderProtocol
    
    /// Is this the current first run (integer not boolean for legacy reasons)
    let currentFirstRun: Int = 1
    
    // MARK: - Initialisation functions
    
    /// Default initialiser for the class
    ///
    /// param: defaultPreferencesName The name of the plist file containing the default preferences
    init(dataProvider: DataProviderProtocol = CloudKeyValueDataProvider()) {

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
                                      showBadge: self.showBadge,
                                      isASupporter: self.isASupporter,
                                      appOpenCount: self.appOpenCount)
        }
    }
    
    // MARK: - Data updating methods
    /// Update the app settings
    /// - Parameters:
    ///   - start: Start date
    ///   - end: End date
    ///   - title: Title
    ///   - weekdaysOnly: Weekdays only?
    func updateAppSettings(start: Date, end: Date, title: String, weekdaysOnly: Bool) {
        self.start = start
        self.end = end
        self.title = title
        self.weekdaysOnly = weekdaysOnly
    }
    
    func incrementAppOpenCount() {
        self.appOpenCount += 1
    }
    
    func updateIsASupporter(_ value: Bool) {
        self.isASupporter = value
    }

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
        set { self.dataProvider.writeObjectToStore(newValue.startOfDay as AnyObject, key: "end") }
    }

    /// Property to get and set the title
    private var title: String {
        get { return self.dataProvider.readObjectFromStore("title") as! String }
        set { self.dataProvider.writeObjectToStore(newValue as AnyObject, key: "title") }
    }

    /// Property to get and set the weekdays only flag
    private var weekdaysOnly: Bool {
        get { return self.dataProvider.readObjectFromStore("weekdaysOnly") as! Bool }
        set { self.dataProvider.writeObjectToStore(newValue as AnyObject, key: "weekdaysOnly") }
    }
    
    /// Property to get and set the firstRun value
    private var firstRun: Int {
        get { return self.dataProvider.readObjectFromStore("firstRun") as! Int }
        set { self.dataProvider.writeObjectToStore(newValue as AnyObject, key: "firstRun") }
    }
    
    /// Property to get and set the show badge flag
    private var showBadge: Bool {
        get { return self.dataProvider.readObjectFromStore("showBadge") as! Bool }
        set { self.dataProvider.writeObjectToStore(newValue as AnyObject, key: "showBadge") }
    }
    
    /// Property to get and set the is a supporter flag (called adsFree because of legacy usage)
    private var isASupporter: Bool {
        get { return self.dataProvider.readObjectFromStore("adsFree") as! Bool }
        set { self.dataProvider.writeObjectToStore(newValue as AnyObject, key: "adsFree") }
    }

    /// Property to get and set the number of times the app has been opened
    private var appOpenCount: Int {
        get { return self.dataProvider.readObjectFromStore("appOpenCount") as! Int }
        set { self.dataProvider.writeObjectToStore(newValue as AnyObject, key: "appOpenCount") }
    }
}
