//
//  ProgressControl.swift
//  daysleft WatchKit Extension
//
//  Created by John Pollard on 13/11/2019.
//  Copyright © 2019 Brave Location Software. All rights reserved.
//

import Foundation
import SwiftUI

struct Arc: Shape, InsettableShape {
    var startAngle: Angle
    var endAngle: Angle
    var clockwise: Bool
    
    var insetAmount: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let rotationAdjustment = Angle.degrees(90)
        let modifiedStart = startAngle - rotationAdjustment
        let modifiedEnd = endAngle - rotationAdjustment

        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2 - insetAmount, startAngle: modifiedStart, endAngle: modifiedEnd, clockwise: !clockwise)

        return path
    }
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.insetAmount += amount
        return arc
    }
}

struct ProgressArc: View {
    var color: Color
    var progress: Double
    var width: CGFloat
    
    var body: some View {
        let progressAngle: Double = (135 * 2) / 100
        let endAngle: Double = -135 + (progressAngle * self.progress)
        
        return Arc(startAngle: .degrees(-135), endAngle: .degrees(endAngle), clockwise: true)
            .strokeBorder(self.color, lineWidth: self.width)
    }
}

struct ProgressControl: View {
    var foregroundColor: Color
    var backgroundColor: Color
    var progress: Double = 0.0
    var width: CGFloat = 50.0

    var body: some View {
        ZStack {
            ProgressArc(color: self.backgroundColor,
                        progress: 100.0,
                        width: self.width)
            ProgressArc(color: self.foregroundColor,
                        progress: self.progress,
                        width: self.width)
        }
    }
}

struct ProgressControl_Previews: PreviewProvider {
    static var previews: some View {
        ProgressControl(foregroundColor: Color.blue,
                        backgroundColor: Color.green,
                        progress: 78.5)
    }
}
