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
    var progress: Double = 0.0
    
    var animatableData: Double {
        get { progress }
        set { self.progress = newValue }
    }

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

struct ProgressControl: View {
    @State private var animationProgress: Double = 0.0
    
    var foregroundColor: Color
    var backgroundColor: Color
    @ObservedObject var model: WatchDaysLeftData

    var lineWidth: CGFloat = 50.0
    var frameSize: CGFloat = 100
    var duration: Double = 0.5

    var body: some View {
        ZStack {
            Arc(progress: 100.0)
                .strokeBorder(self.backgroundColor, lineWidth: self.lineWidth)
                .frame(width: self.frameSize, height: self.frameSize)

            Arc(progress: self.animationProgress)
                .strokeBorder(self.foregroundColor, lineWidth: self.lineWidth)
                .frame(width: self.frameSize, height: self.frameSize)
                .onAppear {
                    withAnimation(.easeInOut(duration: self.duration)) {
                        self.animationProgress = self.model.percentageDone
                    }
                }.onReceive(model.modelChanged, perform: { _ in
                    withAnimation(.easeInOut(duration: self.duration)) {
                        self.animationProgress = self.model.percentageDone
                    }
                })
        }
    }
}

struct ProgressControl_Previews: PreviewProvider {
    static var previews: some View {
        ProgressControl(foregroundColor: Color.blue,
                        backgroundColor: Color.green,
                        model: WatchDaysLeftData())
    }
}
