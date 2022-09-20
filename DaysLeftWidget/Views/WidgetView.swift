//
//  WidgetView.swift
//  DaysLeftWidgetExtension
//
//  Created by John Pollard on 08/09/2020.
//  Copyright © 2020 Brave Location Software. All rights reserved.
//

import Foundation
import SwiftUI
import WidgetKit

struct WidgetView: View {
    
    var model: WidgetDaysLeftData
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .center) {
                Text(self.model.currentTitle)
                    .lineLimit(2)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(Color.primary)
                WidgetProgressControl(
                    foregroundColor: Color("MainAppColor"),
                    backgroundColor: Color("LightAppColor"),
                    model: self.model,
                    lineWidth: 20.0,
                    frameSize: self.progressDimensions(geo.size))
                    .padding()
                Text(self.model.currentPercentageLeft)
                    .font(.footnote)
                    .foregroundColor(Color.primary)
            }.frame(
                width: geo.size.width,
                height: geo.size.height,
                alignment: .center)
        }
        .padding()
        .background(colorScheme == .dark ? Color.black : Color.white)
    }
    
    func progressDimensions(_ screenSize: CGSize) -> CGFloat {
        return screenSize.height / 4.0
    }
}

struct WidgetView_Previews: PreviewProvider {
    static var appSettings = AppSettingsDataManager(dataProvider: InMemoryDataProvider()).appSettings
    
    static var previews: some View {
        Group {
            WidgetView(model: WidgetDaysLeftData(date: Date(), appSettings: appSettings))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            WidgetView(model: WidgetDaysLeftData(date: Date(), appSettings: appSettings))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        
            WidgetView(model: WidgetDaysLeftData(date: Date(), appSettings: appSettings))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .environment(\.colorScheme, .dark)
            WidgetView(model: WidgetDaysLeftData(date: Date(), appSettings: appSettings))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .environment(\.colorScheme, .dark)
        }
    }
}
