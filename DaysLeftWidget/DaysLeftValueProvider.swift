//
//  DaysLeftValueProvider.swift
//  DaysLeft
//
//  Created by John Pollard on 04/08/2024.
//  Copyright © 2024 Brave Location Software. All rights reserved.
//

import WidgetKit

@available(iOS 18.0, *)
struct DaysLeftValueProvider: ControlValueProvider {
    typealias Value = WidgetDaysLeftData
    
    var previewValue: WidgetDaysLeftData {
        let dataManager = AppSettingsDataManager()

        return WidgetDaysLeftData(date: Date(), appSettings: dataManager.appSettings)
    }

    func currentValue() async -> WidgetDaysLeftData {
        let dataManager = AppSettingsDataManager()

        return WidgetDaysLeftData(date: Date(), appSettings: dataManager.appSettings)
    }
}
