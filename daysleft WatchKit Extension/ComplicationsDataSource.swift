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

        NSLog("Getting current timeline entry")
        let now: NSDate = NSDate()
        let entry = self.createTimeLineEntry(complication.family, date:now)
        handler(entry)
    }
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        NSLog("Requesting complication update time")
        handler(NSDate(timeIntervalSinceNow: 60))
    }
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        NSLog("Getting complication placeholder template")
        var template: CLKComplicationTemplate? = nil
        
        switch complication.family {
        case .ModularSmall:
            let modularTemplate = CLKComplicationTemplateModularSmallRingText()
            modularTemplate.textProvider = CLKSimpleTextProvider(text: "--")
            modularTemplate.fillFraction = 0.7
            modularTemplate.ringStyle = CLKComplicationRingStyle.Closed
            template = modularTemplate
        case .ModularLarge:
            template = nil
        case .UtilitarianSmall:
            let modularTemplate = CLKComplicationTemplateUtilitarianSmallRingText()
            modularTemplate.textProvider = CLKSimpleTextProvider(text: "--")
            modularTemplate.fillFraction = 0.7
            modularTemplate.ringStyle = CLKComplicationRingStyle.Closed
            template = modularTemplate
        case .UtilitarianLarge:
            template = nil
        case .CircularSmall:
            let modularTemplate = CLKComplicationTemplateCircularSmallRingText()
            modularTemplate.textProvider = CLKSimpleTextProvider(text: "--")
            modularTemplate.fillFraction = 0.7
            modularTemplate.ringStyle = CLKComplicationRingStyle.Closed
            template = modularTemplate
        }
        
        handler(template)
    }
    
    func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        NSLog("Getting complication privacy")

        handler(CLKComplicationPrivacyBehavior.ShowOnLockScreen)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: ([CLKComplicationTimelineEntry]?) -> Void) {
        NSLog("Getting timeline before date entries")

        handler([])
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: ([CLKComplicationTimelineEntry]?) -> Void) {
        
        NSLog("Getting timeline after date entries")
        handler([])
    }
    
    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {

        NSLog("Getting supported time travel directions")

        // Call the handler with the time travel directions are supported?
        handler([CLKComplicationTimeTravelDirections.None])
        //handler([CLKComplicationTimeTravelDirections.Backward, CLKComplicationTimeTravelDirections.Forward])
    }
    
    func getTimelineStartDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        let model = modelData()
        handler(model.start)
    }
    
    func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        let model = modelData()
        handler(model.end)
    }
    
    func getTimelineAnimationBehaviorForComplication(complication: CLKComplication,
        withHandler handler: (CLKComplicationTimelineAnimationBehavior) -> Void) {
            handler(CLKComplicationTimelineAnimationBehavior.Always)
    }
    
    // Helper methods
    func modelData() -> DaysLeftModel {
        let appDelegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate
        return appDelegate.model
    }
    
    func createTimeLineEntry(family: CLKComplicationFamily, date: NSDate) -> CLKComplicationTimelineEntry? {
        let model = modelData()
        
        // Calculate the data needed for complications
        let currentDaysLeft: Int = model.DaysLeft(date)
        let percentageDone: Float = Float(model.DaysGone(date)) / Float(model.DaysLength)
        //NSLog("Timeline entry", currentDaysLeft, percentageDone)
        
        var entry : CLKComplicationTimelineEntry?
        
        switch family {
            
        case .ModularSmall:
            let template = CLKComplicationTemplateModularSmallRingText()
            template.textProvider = CLKSimpleTextProvider(text: String(currentDaysLeft))
            template.fillFraction = percentageDone
            template.ringStyle = CLKComplicationRingStyle.Closed
            
            entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        case .ModularLarge:
            entry = nil
        case .UtilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallRingText()
            template.textProvider = CLKSimpleTextProvider(text: String(currentDaysLeft))
            template.fillFraction = percentageDone
            template.ringStyle = CLKComplicationRingStyle.Closed
            
            entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        case .UtilitarianLarge:
            entry = nil
        case .CircularSmall:
            let template = CLKComplicationTemplateCircularSmallRingText()
            template.textProvider = CLKSimpleTextProvider(text: String(currentDaysLeft))
            template.fillFraction = percentageDone
            template.ringStyle = CLKComplicationRingStyle.Closed
            
            entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        }
        
        return(entry)
    }
}
