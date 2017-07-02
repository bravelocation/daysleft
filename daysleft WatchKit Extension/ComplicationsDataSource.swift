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

class ComplicationsDataSource : NSObject, CLKComplicationDataSource {
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        let entry = self.createTimeLineEntry(complication.family, date:Date())
        handler(entry)
    }
    
    func getNextRequestedUpdateDate(handler: @escaping (Date?) -> Void) {
        // Update at the start of tomorrow
        let model = modelData()
        let nextUpdate = model.StartOfDay(model.AddDays(Date(), daysToAdd: 1))
        
        print("Setting next extension update to be at \(nextUpdate)")
        
        handler(nextUpdate)
    }
    
    func getPlaceholderTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {

        switch complication.family {
            case .modularSmall:
                let template = CLKComplicationTemplateModularSmallRingText()
                template.textProvider = CLKSimpleTextProvider(text: "--")
                template.fillFraction = 0.7
                template.ringStyle = CLKComplicationRingStyle.open
                handler(template)
            case .utilitarianSmall, .utilitarianSmallFlat:
                let template = CLKComplicationTemplateUtilitarianSmallRingText()
                template.textProvider = CLKSimpleTextProvider(text: "--")
                template.fillFraction = 0.7
                template.ringStyle = CLKComplicationRingStyle.open
                handler(template)
            case .circularSmall:
                let template = CLKComplicationTemplateCircularSmallRingText()
                template.textProvider = CLKSimpleTextProvider(text: "--")
                template.fillFraction = 0.7
                template.ringStyle = CLKComplicationRingStyle.open
                handler(template)
            case .extraLarge:
                let template = CLKComplicationTemplateExtraLargeRingText()
                template.textProvider = CLKSimpleTextProvider(text: "--")
                template.fillFraction = 0.7
                template.ringStyle = CLKComplicationRingStyle.open
                handler(template)
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

        var entries: [CLKComplicationTimelineEntry] = [];
        
        for i in (1...limit).reversed() {
            // Calculate the entry i * 5 mins ago (in chronological order)
            let previousDate = date.addingTimeInterval(-1*60*5*Double(i))
            let entry = self.createTimeLineEntry(complication.family, date:previousDate);
            if (entry != nil) {
                entries.append(entry!)
            }
        }

        handler(entries)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        print("Getting timeline: \(limit) before \(date)")

        var entries: [CLKComplicationTimelineEntry] = [];
        
        for i in 1...limit {
            // Calculate the entry i x 5 mins ahead
            let previousDate = date.addingTimeInterval(60*5*Double(i))
            let entry = self.createTimeLineEntry(complication.family, date:previousDate);
            if (entry != nil) {
                entries.append(entry!)
            }
        }
        
        handler(entries)
    }
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([CLKComplicationTimeTravelDirections.backward, CLKComplicationTimeTravelDirections.forward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(modelData().start as Date)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(modelData().end as Date)
    }
    
    func getTimelineAnimationBehavior(for complication: CLKComplication,
        withHandler handler: @escaping (CLKComplicationTimelineAnimationBehavior) -> Void) {
            handler(CLKComplicationTimelineAnimationBehavior.always)
    }
    
    // Internal helper methods
    fileprivate func modelData() -> DaysLeftModel {
        let appDelegate = WKExtension.shared().delegate as! ExtensionDelegate
        return appDelegate.model
    }
    
    fileprivate func createTimeLineEntry(_ family: CLKComplicationFamily, date: Date) -> CLKComplicationTimelineEntry? {

        let model = modelData()
        let currentDaysLeft: Int = model.DaysLeft(date)
        let percentageDone: Float = Float(model.DaysGone(date)) / Float(model.DaysLength)
        
        var entry : CLKComplicationTimelineEntry?

        switch family {
            case .modularSmall:
                let template = CLKComplicationTemplateModularSmallRingText()
                template.textProvider = CLKSimpleTextProvider(text: String(currentDaysLeft))
                template.fillFraction = percentageDone
                template.ringStyle = CLKComplicationRingStyle.open
                entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            case .utilitarianSmall, .utilitarianSmallFlat:
                let template = CLKComplicationTemplateUtilitarianSmallRingText()
                template.textProvider = CLKSimpleTextProvider(text: String(currentDaysLeft))
                template.fillFraction = percentageDone
                template.ringStyle = CLKComplicationRingStyle.open
                entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            case .circularSmall:
                let template = CLKComplicationTemplateCircularSmallRingText()
                template.textProvider = CLKSimpleTextProvider(text: String(currentDaysLeft))
                template.fillFraction = percentageDone
                template.ringStyle = CLKComplicationRingStyle.open
                entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            case .extraLarge:
                let template = CLKComplicationTemplateExtraLargeRingText()
                template.textProvider = CLKSimpleTextProvider(text: String(currentDaysLeft))
                template.fillFraction = percentageDone
                template.ringStyle = CLKComplicationRingStyle.open
                entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            default:
                entry = nil
        }
        
        return(entry)
    }
}
