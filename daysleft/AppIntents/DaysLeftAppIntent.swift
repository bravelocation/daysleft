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

@available(iOS 16, watchOS 9.0, *)
struct DaysLeftAppIntent: AppIntent, CustomIntentMigratedAppIntent {
    static var title: LocalizedStringResource = "How many days left?"
    static var description = IntentDescription("How many days left?")
    static var openAppWhenRun: Bool = false
    static var intentClassName: String = "DaysLeftIntentHandler"
    
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        let dataManager = AppSettingsDataManager()
        let appSettings = dataManager.appSettings
        
        let now = Date()
        let daysLeft = appSettings.daysLeft(now)
        let daysType = appSettings.weekdaysOnly ? "weekdays" : "days"
        let title = appSettings.title
        
        let spokenText = "There are \(daysLeft) \(daysType) until \(title)"
        
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
