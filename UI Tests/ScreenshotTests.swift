//
//  UI_Tests.swift
//  UI Tests
//
//  Created by John Pollard on 29/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import XCTest

final class ScreenshotTests: XCTestCase {

    @MainActor override func setUp() {
        super.setUp()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments += ["-enable-ui-testing"]
        app.launch()
        
        if self.isIpad() {
            XCUIDevice.shared.orientation = .landscapeLeft
        }
    }

    @MainActor func testMainScreen() throws {
        // Wait for animation to complete
        Thread.sleep(forTimeInterval: 5.0)
        
        snapshot("01Main")
    }
    
    @MainActor func testSettingScreen() throws {
        XCUIApplication().buttons["editButton"].tap()
        snapshot("02Settings")
    }
    
    // MARK: - Helper methods
    
    private func isIpad() -> Bool {
        let window = XCUIApplication().windows.element(boundBy: 0)
        return window.horizontalSizeClass == .regular && window.verticalSizeClass == .regular
    }
}
