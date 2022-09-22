//
//  DaysLeftAppIntent.swift
//  DaysLeft
//
//  Created by John Pollard on 22/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

#if canImport(AppIntents)
import AppIntents

@available(iOS 16, watchOS 9.0, *)
struct DaysLeftAppIntent: AppIntent, CustomIntentMigratedAppIntent {
    static var title: LocalizedStringResource = "How many days left?"
    static var description = IntentDescription("How many days left?")
    static var openAppWhenRun: Bool = false
    static var intentClassName: String = "DaysLeftIntentHandler"
    
    func perform() async throws -> some IntentResult { // } & ShowsSnippetView {
        let dataManager = AppSettingsDataManager()
        let appSettings = dataManager.appSettings
        
        let now = Date()
        let daysLeft = appSettings.daysLeft(now)
        let daysType = appSettings.weekdaysOnly ? "weekdays" : "days"
        let title = appSettings.title
        
        let spokenText = "There are \(daysLeft) \(daysType) until \(title)"

        return .result(value: daysLeft, dialog: IntentDialog(stringLiteral: spokenText))
//        {
//            AppIntentView(currentDate: now, appSettings: appSettings)
//        }
    }
}
#endif
