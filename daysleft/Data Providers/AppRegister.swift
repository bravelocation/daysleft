//
//  AppRegister.swift
//  DaysLeft
//
//  Created by John Pollard on 12/03/2025.
//  Copyright © 2025 Brave Location Software. All rights reserved.
//

import Foundation
#if canImport(ServiceManagement)
import ServiceManagement
#endif
import OSLog

final class AppRegister: Sendable {
    /// Logger
    private let logger = Logger(subsystem: "com.bravelocation.sideboardapp", category: "AppDelegate")
    
    /// Private shared instance
    private static let sharedInstance = AppRegister()
    
    /// Shared instance of app review manager
    class var shared: AppRegister {
        return sharedInstance
    }
    
    func register() {
        #if canImport(ServiceManagement)
            do {
                try SMAppService.mainApp.register()
            } catch {
                self.logger.error("A problem occurred registering the app to run at startup")
            }
        #endif
    }
    
    func unregister() {
        #if canImport(ServiceManagement)
            do {
                try SMAppService.mainApp.unregister()
            } catch {
                self.logger.error("A problem occurred registering the app to run at startup")
            }
        #endif
    }
    
    func canRegister() -> Bool {
        #if canImport(ServiceManagement)
            return true
        #else
            return false
        #endif
    }
    
    func isRegistered() -> Bool {
        #if canImport(ServiceManagement)
            return SMAppService.mainApp.status == .enabled
        #else
            return false
        #endif
    }
}
