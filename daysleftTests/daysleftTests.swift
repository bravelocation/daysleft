//
//  daysleftTests.swift
//  daysleftTests
//
//  Created by John Pollard on 11/02/2015.
//  Copyright (c) 2015 Brave Location Software. All rights reserved.
//

import UIKit
import XCTest
import daysleftlibrary

class daysleftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAllDaysCalculations() {
        // It's 5 days from the 1st to the 5th, and if we are on the 4th there is 1 day left (so 4 gone)
        self.actualTestRun(1, endDay:5, currentDay:4, weekdaysOnly:false, expectedLength:5, expectedGone:4, expectedLeft:1)
    }
    
    func testAllDaysOnLastDay() {
        // On the last day, all the days have gone
        self.actualTestRun(1, endDay:15, currentDay:15, weekdaysOnly:false, expectedLength:15, expectedGone:15, expectedLeft:0)
    }
    
    func testAllDaysAfterLastDay() {
        // After the last day, so all the days have gone
        self.actualTestRun(1, endDay:15, currentDay:16, weekdaysOnly:false, expectedLength:15, expectedGone:15, expectedLeft:0)
    }

    
    func testAllDaysOnFirstDay() {
        // On the first day, so one day has gone
        self.actualTestRun(1, endDay:15, currentDay:1, weekdaysOnly:false, expectedLength:15, expectedGone:1, expectedLeft:14)
    }

    func testAllDaysBeforeFirstDay() {
        // Before the start, so all the days are left
        self.actualTestRun(10, endDay:15, currentDay:8, weekdaysOnly:false, expectedLength:6, expectedGone:0, expectedLeft:6)
    }
    
    func testWeekdaysCalculations() {
        // 1st of Jan is a Thursday
        // 12th of Jan is a Monday
        // So that's 8 weekdays in length
        // If today is Wednesday 7th, that's 5 days gone (Thu, Fri, Mon, Tue, Wed), 3 days to go (Wed, Thu, Fri)
        self.actualTestRun(1, endDay:12, currentDay:7, weekdaysOnly:true, expectedLength:8, expectedGone:5, expectedLeft:3)
    }
    
    func testWeekdaysStartOnSaturdayEndOnMonday() {
        // 3rd of Jan is a Saturday
        // 12th of Jan is a Monday
        // So that's 6 weekdays in length
        // If today is Wednesday 7th, that's 3 days gone (Mon, Tue, Wed), 3 days to go (Wed, Thu, Fri)
        self.actualTestRun(3, endDay:12, currentDay:7, weekdaysOnly:true, expectedLength:6, expectedGone:3, expectedLeft:3)
    }
    
    func testWeekdaysStartOnSundayEndOnMonday() {
        // 4th of Jan is a Sunday
        // 12th of Jan is a Monday
        // So that's 6 weekdays in length
        // If today is Wednesday 7th, that's 3 days gone (Mon, Tue, Wed), 3 days to go (Wed, Thu, Fri)
        self.actualTestRun(4, endDay:12, currentDay:7, weekdaysOnly:true, expectedLength:6, expectedGone:3, expectedLeft:3)
    }
    
    func testWeekdaysStartOnTuesdayEndOnSunday() {
        // 6th of Jan is a Tuesday
        // 11th of Jan is a Sunday
        // So that's 4 weekdays in length
        // If today is Wednesday 7th, that's 2 days gone (Tue, Wed), 2 days to go (Wed, Thu)
        self.actualTestRun(6, endDay:11, currentDay:7, weekdaysOnly:true, expectedLength:4, expectedGone:2, expectedLeft:2)
    }
    
    func testWeekdaysStartOnSaturdayEndOnSunday() {
        // 3rd of Jan is a Saturday
        // 11th of Jan is a Sunday
        // So that's 5 weekdays in length
        // If today is Wednesday 7th, that's 3 days gone (Mon, Tue, Wed), 2 days to go (Thur, Thu)
        self.actualTestRun(3, endDay:11, currentDay:7, weekdaysOnly:true, expectedLength:5, expectedGone:3, expectedLeft:2)
    }
    
    // Helper method for running tests
    func actualTestRun(startDay: Int, endDay: Int, currentDay: Int, weekdaysOnly: Bool, expectedLength: Int, expectedGone: Int, expectedLeft: Int) {
        var model: DaysLeftModel = DaysLeftModel()
        model.weekdaysOnly = weekdaysOnly
        
        var startComponents: NSDateComponents = NSDateComponents();
        startComponents.year = 2015;
        startComponents.month = 1;
        startComponents.day = startDay;
        
        var endComponents: NSDateComponents = NSDateComponents();
        endComponents.year = 2015;
        endComponents.month = 1;
        endComponents.day = endDay;
        
        var currentComponents: NSDateComponents = NSDateComponents();
        currentComponents.year = 2015;
        currentComponents.month = 1;
        currentComponents.day = currentDay;
        
        model.start = NSCalendar.autoupdatingCurrentCalendar().dateFromComponents(startComponents)!
        model.end = NSCalendar.autoupdatingCurrentCalendar().dateFromComponents(endComponents)!
        let currentDate: NSDate = NSCalendar.autoupdatingCurrentCalendar().dateFromComponents(currentComponents)!
        
        XCTAssertEqual(expectedLength, model.DaysLength, "DaysLength is correct")
        XCTAssertEqual(expectedGone, model.DaysGone(currentDate), "DaysGone is correct")
        XCTAssertEqual(expectedLeft, model.DaysLeft(currentDate), "DaysLeft is correct")
        
    }
}
