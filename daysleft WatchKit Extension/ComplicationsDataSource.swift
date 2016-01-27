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
    
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimelineEntry?) -> Void) {
        let entry = self.createTimeLineEntry(complication.family, date:NSDate())
        handler(entry)
    }
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        // Update at the start of tomorrow
        let model = modelData()
        let nextUpdate = model.StartOfDay(model.AddDays(NSDate(), daysToAdd: 1))
        
        NSLog("Setting next extension update to be at %@", nextUpdate)
        
        handler(nextUpdate)
    }
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {

        switch complication.family {
            case .ModularSmall:
                let template = CLKComplicationTemplateModularSmallRingText()
                template.textProvider = CLKSimpleTextProvider(text: "--")
                template.fillFraction = 0.7
                template.ringStyle = CLKComplicationRingStyle.Open
                handler(template)
            case .UtilitarianSmall:
                let template = CLKComplicationTemplateUtilitarianSmallRingText()
                template.textProvider = CLKSimpleTextProvider(text: "--")
                template.fillFraction = 0.7
                template.ringStyle = CLKComplicationRingStyle.Open
                handler(template)
            case .CircularSmall:
                let template = CLKComplicationTemplateCircularSmallRingText()
                template.textProvider = CLKSimpleTextProvider(text: "--")
                template.fillFraction = 0.7
                template.ringStyle = CLKComplicationRingStyle.Open
                handler(template)
            default:
                handler(nil)
        }
    }
    
    func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        // Show the complication on the lock screen
        handler(CLKComplicationPrivacyBehavior.HideOnLockScreen)
    }
    
    // --- Timeline functions ---

    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: ([CLKComplicationTimelineEntry]?) -> Void) {
        NSLog("Getting timeline: %d before %@", limit, date)

        var entries: [CLKComplicationTimelineEntry] = [];
        
        for var i = limit; i >= 1; i-- {
            // Calculate the entry i * 5 mins ago (in chronological order)
            let previousDate = date.dateByAddingTimeInterval(-1*60*5*Double(i))
            let entry = self.createTimeLineEntry(complication.family, date:previousDate);
            if (entry != nil) {
                entries.append(entry!)
            }
        }

        handler(entries)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: ([CLKComplicationTimelineEntry]?) -> Void) {
        NSLog("Getting timeline: %d after %@", limit, date)

        var entries: [CLKComplicationTimelineEntry] = [];
        
        for var i = 1; i <= limit; i++ {
            // Calculate the entry i x 5 mins ahead
            let previousDate = date.dateByAddingTimeInterval(60*5*Double(i))
            let entry = self.createTimeLineEntry(complication.family, date:previousDate);
            if (entry != nil) {
                entries.append(entry!)
            }
        }
        
        handler(entries)
    }
    
    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
        handler([CLKComplicationTimeTravelDirections.Backward, CLKComplicationTimeTravelDirections.Forward])
    }
    
    func getTimelineStartDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(modelData().start)
    }
    
    func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(modelData().end)
    }
    
    func getTimelineAnimationBehaviorForComplication(complication: CLKComplication,
        withHandler handler: (CLKComplicationTimelineAnimationBehavior) -> Void) {
            handler(CLKComplicationTimelineAnimationBehavior.Always)
    }
    
    // Internal helper methods
    private func modelData() -> DaysLeftModel {
        let appDelegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate
        return appDelegate.model
    }
    
    private func createTimeLineEntry(family: CLKComplicationFamily, date: NSDate) -> CLKComplicationTimelineEntry? {

        let model = modelData()
        let currentDaysLeft: Int = model.DaysLeft(date)
        let percentageDone: Float = Float(model.DaysGone(date)) / Float(model.DaysLength)
        
        var entry : CLKComplicationTimelineEntry?

        switch family {
            case .ModularSmall:
                let template = CLKComplicationTemplateModularSmallRingText()
                template.textProvider = CLKSimpleTextProvider(text: String(currentDaysLeft))
                template.fillFraction = percentageDone
                template.ringStyle = CLKComplicationRingStyle.Open
                entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            case .UtilitarianSmall:
                let template = CLKComplicationTemplateUtilitarianSmallRingText()
                template.textProvider = CLKSimpleTextProvider(text: String(currentDaysLeft))
                template.fillFraction = percentageDone
                template.ringStyle = CLKComplicationRingStyle.Open
                entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            case .CircularSmall:
                let template = CLKComplicationTemplateCircularSmallRingText()
                template.textProvider = CLKSimpleTextProvider(text: String(currentDaysLeft))
                template.fillFraction = percentageDone
                template.ringStyle = CLKComplicationRingStyle.Open
                entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            default:
                entry = nil
        }
        
        return(entry)
    }
}
