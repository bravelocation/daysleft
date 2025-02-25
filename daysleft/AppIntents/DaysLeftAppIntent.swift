//
//  DaysLeftAppIntent.swift
//  DaysLeft
//
//  Created by John Pollard on 22/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

#if canImport(AppIntents)
import AppIntents
import SwiftUI

/// App Intent definition for the accessing of the data via Siri shortcuts
struct DaysLeftAppIntent: AppIntent, CustomIntentMigratedAppIntent {
    /// Title of the intent
    static let title: LocalizedStringResource = "How many days left?"
    
    /// Description of the intent
    static let description = IntentDescription("How many days left?")
    
    /// The app shouldn't be opened when the intent is run
    static let openAppWhenRun: Bool = false
    
    /// Class name of the previous intent handler
    static let intentClassName: String = "DaysLeftIntentHandler"
    
    /// Handler to perform the intent
    /// - Returns: The intent will return a visual snippet, plus the number of days left as a result
    func perform() async throws -> some IntentResult & ShowsSnippetView & ProvidesDialog & ReturnsValue<Int> {
        let dataManager = AppSettingsDataManager()
        let appSettings = dataManager.appSettings
        
        let now = Date()
        let daysLeft = appSettings.daysLeft(now)
        
        var daysType = ""
        
        if appSettings.weekdaysOnly {
            let localised = NSLocalizedString("weekdays", comment: "")
            daysType = String(format: localised, daysLeft)
        } else {
            let localised = NSLocalizedString("days", comment: "")
            daysType = String(format: localised, daysLeft)
        }
                
        let localisedString = NSLocalizedString("App Intent Response", comment: "")
        let spokenText = String(format: localisedString, daysLeft, daysType, appSettings.title)
                
        let progress = appSettings.percentageDone(date: now)
        let percentageDone = appSettings.currentPercentageLeft(date: now)

        return .result(value: daysLeft,
                       dialog: IntentDialog(stringLiteral: spokenText)) {
            VStack(alignment: .center) {
                CircularProgressView(progress: progress,
                                     lineWidth: 20.0)
                    .padding([.top, .bottom], 16.0)
                    .frame(width: 100.0, height: 100.0)
                
                Text(percentageDone)
                    .font(.footnote)
            }
            .padding()
        }
    }
}
#endif
