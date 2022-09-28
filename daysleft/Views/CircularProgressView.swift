//
//  CircularProgressView.swift
//  DaysLeft
//
//  Created by John Pollard on 21/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let lineWidth: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color("LightAppColor"),
                    lineWidth: self.lineWidth
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color("MainAppColor"),
                    style: StrokeStyle(
                        lineWidth: self.lineWidth
                    )
                )
                .rotationEffect(.degrees(-90))
        }
    }
}

struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressView(progress: 0.4, lineWidth: 20.0)
    }
}
