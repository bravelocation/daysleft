//
//  ComplicationsDataSource.swift
//  daysleft
//
//  Created by John Pollard on 12/10/2015.
//  Copyright © 2015 Brave Location Software. All rights reserved.
//

import Foundation
import WatchKit
import ClockKit

/// Legacy complications data source
@available(watchOS, deprecated: 9.0, message: "Remove legacy complications data source once people have updated")
class ComplicationsDataSource: NSObject, CLKComplicationDataSource {
    
    /// App settings
    let appSettings = AppSettingsDataManager().appSettings
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        let entry = self.createTimeLineEntry(complication.family, date: Date())
        handler(entry)
    }
    
    func getNextRequestedUpdateDate(handler: @escaping (Date?) -> Void) {
        // Update at the start of tomorrow
        let nextUpdate = Date().addDays(1).startOfDay
        
        print("Setting next extension update to be at \(nextUpdate)")
        
        handler(nextUpdate)
    }
    
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let mySupportedFamilies = CLKComplicationFamily.allCases

        let daysLeftDescriptor = CLKComplicationDescriptor(
            identifier: "ComplicationDaysLeft",
            displayName: "Count The Days Left",
            supportedFamilies: mySupportedFamilies)
        
        handler([daysLeftDescriptor])
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    func getLocalizableSampleTemplate(for complication: CLKComplication,
                                      withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        let appTintColor = UIColor(red: 203/255, green: 237/255, blue: 142/255, alpha: 1.0)

        switch complication.family {
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallRingText(textProvider: CLKSimpleTextProvider(text: "--"),
                                                                        fillFraction: 0.7,
                                                                        ringStyle: CLKComplicationRingStyle.open)
            handler(template)
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallRingText(textProvider: CLKSimpleTextProvider(text: "--"),
                                                                       fillFraction: 0.7,
                                                                       ringStyle: CLKComplicationRingStyle.open)
            handler(template)
        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallRingText(textProvider: CLKSimpleTextProvider(text: "--"),
                                                                           fillFraction: 0.7,
                                                                           ringStyle: CLKComplicationRingStyle.open)
            handler(template)
        case .utilitarianSmallFlat:
            let template = CLKComplicationTemplateUtilitarianSmallFlat(textProvider: CLKSimpleTextProvider(text: "--"))
            handler(template)
        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat(textProvider: CLKSimpleTextProvider(text: "--"))
            handler(template)
        case .extraLarge:
            let template = CLKComplicationTemplateExtraLargeRingText(textProvider: CLKSimpleTextProvider(text: "--"),
                                                                     fillFraction: 0.7,
                                                                     ringStyle: CLKComplicationRingStyle.open)
            handler(template)
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody(headerTextProvider: CLKSimpleTextProvider(text: "Christmas"),
                                                                           body1TextProvider: CLKSimpleTextProvider(text: "30 days"),
                                                                           body2TextProvider: CLKSimpleTextProvider(text: "10% done"))
            handler(template)
        case .graphicBezel:
            let gauge = CLKSimpleGaugeProvider(style: .fill, gaugeColor: appTintColor, fillFraction: 0.1)
            let gaugeProvider = CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText(gaugeProvider: gauge,
                                                                                          bottomTextProvider: CLKSimpleTextProvider(text: String(format: "%d%%", 10)),
                                                                                          centerTextProvider: CLKSimpleTextProvider(text: String("20")))
            
            let template = CLKComplicationTemplateGraphicBezelCircularText(circularTemplate: gaugeProvider,
                                                                           textProvider: CLKSimpleTextProvider(text: "20 days until Christmas"))
            template.tintColor = appTintColor
            
            handler(template)
        case .graphicCorner:
            let gauge = CLKSimpleGaugeProvider(style: .fill, gaugeColor: appTintColor, fillFraction: 0.1)
            let template = CLKComplicationTemplateGraphicCornerGaugeText(gaugeProvider: gauge,
                                                                         outerTextProvider: CLKSimpleTextProvider(text: "20 days"))
            template.tintColor = appTintColor
            handler(template)
        case .graphicCircular:
            let gauge = CLKSimpleGaugeProvider(style: .fill, gaugeColor: appTintColor, fillFraction: 0.1)

            let template = CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText(gaugeProvider: gauge,
                                                                                     bottomTextProvider: CLKSimpleTextProvider(text: String(format: "%d%%", 10)),
                                                                                     centerTextProvider: CLKSimpleTextProvider(text: "20"))
            template.tintColor = appTintColor
            handler(template)
        case .graphicRectangular:
                let template = CLKComplicationTemplateGraphicRectangularStandardBody(headerTextProvider: CLKSimpleTextProvider(text: "Christmas"),
                                                                                     body1TextProvider: CLKSimpleTextProvider(text: "20 days"),
                                                                                     body2TextProvider: CLKSimpleTextProvider(text: String(format: "%d%% done", 0.1)))
                template.tintColor = appTintColor
                
                handler(template)
        case .graphicExtraLarge:
            if #available(watchOS 7, *) {
                let gauge = CLKSimpleGaugeProvider(style: .fill, gaugeColor: appTintColor, fillFraction: 0.1)

                let template = CLKComplicationTemplateGraphicExtraLargeCircularOpenGaugeRangeText(gaugeProvider: gauge,
                                                                                                  leadingTextProvider: CLKSimpleTextProvider(text: ""),
                                                                                                  trailingTextProvider: CLKSimpleTextProvider(text: ""),
                                                                                                  centerTextProvider: CLKSimpleTextProvider(text: "20"))
                template.tintColor = appTintColor
                
                handler(template)
            }
        default:
            handler(nil)
        }
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        // Show the complication on the lock screen
        handler(CLKComplicationPrivacyBehavior.hideOnLockScreen)
    }
    
    // --- Timeline functions ---

    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        print("Getting timeline: \(limit) before \(date)")

        var entries: [CLKComplicationTimelineEntry] = []
        
        for i in (1...limit).reversed() {
            // Calculate the entry i * 5 mins ago (in chronological order)
            let previousDate = date.addingTimeInterval(-1*60*5*Double(i))
            let entry = self.createTimeLineEntry(complication.family, date: previousDate)
            if entry != nil {
                entries.append(entry!)
            }
        }

        handler(entries)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        print("Getting timeline: \(limit) before \(date)")

        var entries: [CLKComplicationTimelineEntry] = []
        
        for i in 1...limit {
            // Calculate the entry i x 5 mins ahead
            let previousDate = date.addingTimeInterval(60*5*Double(i))
            let entry = self.createTimeLineEntry(complication.family, date: previousDate)
            if entry != nil {
                entries.append(entry!)
            }
        }
        
        handler(entries)
    }
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([CLKComplicationTimeTravelDirections.backward, CLKComplicationTimeTravelDirections.forward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(self.appSettings.start as Date)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(self.appSettings.end as Date)
    }
    
    func getTimelineAnimationBehavior(for complication: CLKComplication,
                                      withHandler handler: @escaping (CLKComplicationTimelineAnimationBehavior) -> Void) {
            handler(CLKComplicationTimelineAnimationBehavior.always)
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    fileprivate func createTimeLineEntry(_ family: CLKComplicationFamily, date: Date) -> CLKComplicationTimelineEntry? {

        let currentDaysLeft: Int = self.appSettings.daysLeft(date)
        let percentageDone: Float = (Float(self.appSettings.daysGone(date)) / Float(self.appSettings.daysLength)).clamped(to: 0.0...1.0)
        let displayPercentageDone: Int = (Int) (percentageDone * 100)
        let appTintColor = UIColor(red: 203/255, green: 237/255, blue: 142/255, alpha: 1.0)
        
        var entry: CLKComplicationTimelineEntry?

        switch family {
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallRingText(textProvider: CLKSimpleTextProvider(text: String(currentDaysLeft)),
                                                                        fillFraction: percentageDone,
                                                                        ringStyle: CLKComplicationRingStyle.open)
            template.tintColor = appTintColor
            entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallRingText(textProvider: CLKSimpleTextProvider(text: String(currentDaysLeft)),
                                                                       fillFraction: percentageDone,
                                                                       ringStyle: CLKComplicationRingStyle.open)
            template.tintColor = appTintColor
            entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallRingText(textProvider: CLKSimpleTextProvider(text: String(currentDaysLeft)),
                                                                           fillFraction: percentageDone,
                                                                           ringStyle: CLKComplicationRingStyle.open)
            template.tintColor = appTintColor
            entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        case .utilitarianSmallFlat:
            let template = CLKComplicationTemplateUtilitarianSmallFlat(textProvider: CLKSimpleTextProvider(text: String(currentDaysLeft)))
            template.tintColor = appTintColor
            entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat(textProvider: CLKSimpleTextProvider(text: String(currentDaysLeft)))
            template.tintColor = appTintColor
            entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        case .extraLarge:
            let template = CLKComplicationTemplateExtraLargeRingText(textProvider: CLKSimpleTextProvider(text: String(currentDaysLeft)),
                                                                     fillFraction: percentageDone,
                                                                     ringStyle: CLKComplicationRingStyle.open)
            template.tintColor = appTintColor
            entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody(headerTextProvider: CLKSimpleTextProvider(text: self.appSettings.title),
                                                                           body1TextProvider: CLKSimpleTextProvider(text: String(format: "%d days", currentDaysLeft)),
                                                                           body2TextProvider: CLKSimpleTextProvider(text: String(format: "%d%% done", displayPercentageDone)))
            template.tintColor = appTintColor
            entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        case .graphicBezel:
            let gauge = CLKSimpleGaugeProvider(style: .fill, gaugeColor: appTintColor, fillFraction: percentageDone)

            let gaugeProvider = CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText(gaugeProvider: gauge,
                                                                                          bottomTextProvider: CLKSimpleTextProvider(text: String(format: "%d%%", displayPercentageDone)),
                                                                                          centerTextProvider: CLKSimpleTextProvider(text: String(currentDaysLeft)))

            let longDesc = String(format: "%d %@ until %@", currentDaysLeft, self.appSettings.weekdaysOnly ? "weekdays" : "days", self.appSettings.title)

            let template = CLKComplicationTemplateGraphicBezelCircularText(circularTemplate: gaugeProvider,
                                                                           textProvider: CLKSimpleTextProvider(text: longDesc))
            template.tintColor = appTintColor
            entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        case .graphicCorner:
            let gauge = CLKSimpleGaugeProvider(style: .fill, gaugeColor: appTintColor, fillFraction: percentageDone)
            let daysDesc = String(format: "%d days", currentDaysLeft)
            let template = CLKComplicationTemplateGraphicCornerGaugeText(gaugeProvider: gauge,
                                                                         outerTextProvider: CLKSimpleTextProvider(text: daysDesc))
            template.tintColor = appTintColor
            entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        case .graphicCircular:
            let gauge = CLKSimpleGaugeProvider(style: .fill, gaugeColor: appTintColor, fillFraction: percentageDone)

            let template = CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText(gaugeProvider: gauge,
                                                                                     bottomTextProvider: CLKSimpleTextProvider(text: String(format: "%d%%", displayPercentageDone)),
                                                                                     centerTextProvider: CLKSimpleTextProvider(text: String(currentDaysLeft)))
            template.tintColor = appTintColor
            entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        case .graphicRectangular:
            let template = CLKComplicationTemplateGraphicRectangularStandardBody(headerTextProvider: CLKSimpleTextProvider(text: self.appSettings.title),
                                                                                 body1TextProvider: CLKSimpleTextProvider(text: String(format: "%d days", currentDaysLeft)),
                                                                                 body2TextProvider: CLKSimpleTextProvider(text: String(format: "%d%% done", displayPercentageDone)))
            template.tintColor = appTintColor
            
            entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        case .graphicExtraLarge:
            if #available(watchOS 7, *) {
                let gauge = CLKSimpleGaugeProvider(style: .fill, gaugeColor: appTintColor, fillFraction: 0.1)

                let template = CLKComplicationTemplateGraphicExtraLargeCircularOpenGaugeRangeText(gaugeProvider: gauge,
                                                                                                  leadingTextProvider: CLKSimpleTextProvider(text: ""),
                                                                                                  trailingTextProvider: CLKSimpleTextProvider(text: ""),
                                                                                                  centerTextProvider: CLKSimpleTextProvider(text: String(format: "%d", currentDaysLeft)))
                template.tintColor = appTintColor
                entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            }
        default:
            break
        }
        
        return(entry)
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
