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
    
    @ObservedObject var model: WidgetDaysLeftData
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .center) {
                Text(self.model.currentTitle)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.primary)
                Text(self.model.currentSubTitle)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.primary)
                WidgetProgressControl(foregroundColor: Color("LightAppColor"),
                                backgroundColor: Color("MainAppColor"),
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
        if (screenSize.width > screenSize.height) {
            return screenSize.height - 100
        } else {
            return screenSize.width - 100
        }
    }
}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WidgetView(model: WidgetDaysLeftData(date: Date()))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            WidgetView(model: WidgetDaysLeftData(date: Date()))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        
            WidgetView(model: WidgetDaysLeftData(date: Date()))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .environment(\.colorScheme, .dark)
            WidgetView(model: WidgetDaysLeftData(date: Date()))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .environment(\.colorScheme, .dark)
        }
    }
}
