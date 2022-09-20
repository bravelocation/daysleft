//
//  WidgetProgressControl.swift
//  DaysLeftWidgetExtension
//
//  Created by John Pollard on 08/09/2020.
//  Copyright © 2020 Brave Location Software. All rights reserved.
//

import Foundation
import SwiftUI
import WidgetKit

struct Arc: Shape, InsettableShape {
    var progress: Double = 0.0

    func path(in rect: CGRect) -> Path {
        let rotationAdjustment = Angle.degrees(90)
        let modifiedStart = .degrees(-135) - rotationAdjustment
        
        let progressAngle: Double = (135 * 2) / 100
        let endAngle: Double = -135 + (progressAngle * self.progress)

        let modifiedEnd = .degrees(endAngle) - rotationAdjustment

        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: modifiedStart, endAngle: modifiedEnd, clockwise: false)

        return path
    }
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        return self
    }
}

struct WidgetProgressControl: View {
    var foregroundColor: Color
    var backgroundColor: Color
    var model: WidgetDaysLeftData

    var lineWidth: CGFloat = 20.0
    var frameSize: CGFloat = 100

    var body: some View {
        ZStack {
            Arc(progress: 100.0)
                .strokeBorder(self.backgroundColor, lineWidth: self.lineWidth)
                .frame(width: self.frameSize, height: self.frameSize)

            Arc(progress: self.model.percentageDone)
                .strokeBorder(self.foregroundColor, lineWidth: self.lineWidth)
                .frame(width: self.frameSize, height: self.frameSize)
        }
    }
}

struct WidgetProgressControl_Previews: PreviewProvider {
    static var appSettings = AppSettingsDataManager(dataProvider: InMemoryDataProvider()).appSettings
    
    static var previews: some View {
        Group {
            WidgetProgressControl(foregroundColor: Color.blue,
                            backgroundColor: Color.green,
                            model: WidgetDaysLeftData(date: Date(), appSettings: appSettings))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            WidgetProgressControl(foregroundColor: Color.blue,
                            backgroundColor: Color.green,
                            model: WidgetDaysLeftData(date: Date(), appSettings: appSettings))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }

    }
}
