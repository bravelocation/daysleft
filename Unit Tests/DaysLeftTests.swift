//
//  daysleftTests.swift
//  daysleftTests
//
//  Created by John Pollard on 11/02/2015.
//  Copyright (c) 2015 Brave Location Software. All rights reserved.
//

import UIKit
import XCTest

class DaysLeftTests: XCTestCase {
    
    func testAllDaysCalculations() {
        // It's 5 days from the 1st to the 5th, and if we are on the 4th there is 1 day left (so 4 gone)
        self.actualTestRun(startDay: 1, endDay: 5, currentDay: 4, weekdaysOnly: false, expectedLength: 5, expectedGone: 4, expectedLeft: 1)
    }
    
    func testAllDaysOnLastDay() {
        // On the last day, all the days have gone
        self.actualTestRun(startDay: 1, endDay: 15, currentDay: 15, weekdaysOnly: false, expectedLength: 15, expectedGone: 15, expectedLeft: 0)
    }
    
    func testAllDaysAfterLastDay() {
        // After the last day, so all the days have gone
        self.actualTestRun(startDay: 1, endDay: 15, currentDay: 16, weekdaysOnly: false, expectedLength: 15, expectedGone: 15, expectedLeft: 0)
    }

    func testAllDaysOnFirstDay() {
        // On the first day, so one day has gone
        self.actualTestRun(startDay: 10, endDay: 15, currentDay: 10, weekdaysOnly: false, expectedLength: 6, expectedGone: 1, expectedLeft: 5)
    }

    func testAllDaysBeforeFirstDay() {
        // Before the start, so all the days are left
        self.actualTestRun(startDay: 10, endDay: 15, currentDay: 8, weekdaysOnly: false, expectedLength: 6, expectedGone: 0, expectedLeft: 6)
    }
    
    func testWeekdaysCalculations() {
        // 1st of Jan is a Thursday
        // 12th of Jan is a Monday
        // So that's 8 weekdays in length (T,F,M,T,W,T,F,M)
        // If today is Wednesday 7th, that's 5 days gone (T,F,M,T,W), 3 days to go (T,F,M)
        self.actualTestRun(startDay: 1, endDay: 12, currentDay: 7, weekdaysOnly: true, expectedLength: 8, expectedGone: 5, expectedLeft: 3)
    }

    func testWeekdaysOnMiddleWeekendCalculations() {
        // 5th of Jan is a Monday
        // 16th of Jan is a Friday
        // So that's 10 weekdays in length
        // If today is Sunday 11th, that's 5 days gone, 5 days to go
        self.actualTestRun(startDay: 5, endDay: 16, currentDay: 11, weekdaysOnly: true, expectedLength: 10, expectedGone: 5, expectedLeft: 5)
    }
    
    func testWeekdaysStartOnSaturdayEndOnMonday() {
        // 3rd of Jan is a Saturday
        // 12th of Jan is a Monday
        // So that's 6 weekdays in length
        // If today is Wednesday 7th, that's 3 days gone (Mon, Tue, Wed), 3 days to go (Wed, Thu, Fri)
        self.actualTestRun(startDay: 3, endDay: 12, currentDay: 7, weekdaysOnly: true, expectedLength: 6, expectedGone: 3, expectedLeft: 3)
    }
    
    func testWeekdaysStartOnSundayEndOnMonday() {
        // 4th of Jan is a Sunday
        // 12th of Jan is a Monday
        // So that's 6 weekdays in length
        // If today is Wednesday 7th, that's 3 days gone (Mon, Tue, Wed), 3 days to go (Thu, Fri, Mon)
        self.actualTestRun(startDay: 4, endDay: 12, currentDay: 7, weekdaysOnly: true, expectedLength: 6, expectedGone: 3, expectedLeft: 3)
    }
    
    func testWeekdaysStartOnTuesdayEndOnSunday() {
        // 6th of Jan is a Tuesday
        // 11th of Jan is a Sunday
        // So that's 4 weekdays in length
        // If today is Wednesday 7th, that's 2 days gone (Tue, Wed), 2 days to go (Wed, Thu)
        self.actualTestRun(startDay: 6, endDay: 11, currentDay: 7, weekdaysOnly: true, expectedLength: 4, expectedGone: 2, expectedLeft: 2)
    }
    
    func testWeekdaysStartOnSaturdayEndOnSunday() {
        // 3rd of Jan is a Saturday
        // 11th of Jan is a Sunday
        // So that's 5 weekdays in length
        // If today is Wednesday 7th, that's 3 days gone (Mon, Tue, Wed), 2 days to go (Thur, Thu)
        self.actualTestRun(startDay: 3, endDay: 11, currentDay: 7, weekdaysOnly: true, expectedLength: 5, expectedGone: 3, expectedLeft: 2)
    }
    
    func testWeekdaysStartOnCurrentWeekendDayEndOnMonday() {
        // 4th of Jan is a Sunday
        // 12th of Jan is a Monday
        // So that's 6 weekdays in length
        // If today is Sunday 4th, that's 0 days gone, 6 days to go
        self.actualTestRun(startDay: 4, endDay: 12, currentDay: 4, weekdaysOnly: true, expectedLength: 6, expectedGone: 0, expectedLeft: 6)
    }
    
    // Helper method for running tests
    func actualTestRun(startDay: Int, endDay: Int, currentDay: Int, weekdaysOnly: Bool, expectedLength: Int, expectedGone: Int, expectedLeft: Int) {
        let model = AppSettingsDataManager(dataProvider: InMemoryDataProvider.shared)
        
        var startComponents: DateComponents = DateComponents()
        startComponents.year = 2015
        startComponents.month = 1
        startComponents.day = startDay
        model.updateStartDate(Calendar.current.date(from: startComponents)!)
        
        var endComponents: DateComponents = DateComponents()
        endComponents.year = 2015
        endComponents.month = 1
        endComponents.day = endDay
        model.updateEndDate(Calendar.current.date(from: endComponents)!)
        
        model.updateTitle("Test")
        model.updateWeekdaysOnly(weekdaysOnly)
        
        var currentComponents: DateComponents = DateComponents()
        currentComponents.year = 2015
        currentComponents.month = 1
        currentComponents.day = currentDay
        
        let currentDate: Date = Calendar.current.date(from: currentComponents)!
        
        XCTAssertEqual(expectedLength, model.appSettings.daysLength, "DaysLength is incorrect")
        XCTAssertEqual(expectedGone, model.appSettings.daysGone(currentDate), "DaysGone is incorrect")
        XCTAssertEqual(expectedLeft, model.appSettings.daysLeft(currentDate), "DaysLeft is incorrect")
    }
}
