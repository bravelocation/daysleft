//
//  AccessoryRectangularView.swift
//  DaysLeftWidgetExtension
//
//  Created by John Pollard on 22/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import SwiftUI
import WidgetKit

/// Accessory rectangular view
@available(iOSApplicationExtension 16.0, *)
struct AccessoryRectangularView: View {
    /// View model
    var model: WidgetDaysLeftData
    
    /// View body
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(self.model.displayValues.title.capitalizingFirstLetter())
                    .widgetAccentable()
                
                Text("\(self.model.displayValues.daysLeftDescription) \(NSLocalizedString("Time Left", comment: ""))")
                Text(self.model.displayValues.currentPercentageLeft)
                    .font(.footnote)
            }
            
            Spacer()
        }
        .padding([.leading, .trailing], 4.0)
    }
}

/// Preview provider for AccessoryRectangularView
@available(iOSApplicationExtension 16.0, *)
struct AccessoryRectangularView_Previews: PreviewProvider {
    static var appSettings = AppSettingsDataManager(dataProvider: InMemoryDataProvider.shared).appSettings

    static var previews: some View {
        AccessoryRectangularView(model: WidgetDaysLeftData(date: Date(), appSettings: appSettings))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
