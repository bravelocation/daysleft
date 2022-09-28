//
//  CircularProgressView.swift
//  DaysLeft
//
//  Created by John Pollard on 21/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import SwiftUI

/// A circular progress view
struct CircularProgressView: View {
    /// Progress value - should be between 0.0 and 1.0
    let progress: Double
    
    /// Line width of progress circle
    let lineWidth: Double
    
    /// Body of view
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

/// Preview provider for CircularProgressView
struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressView(progress: 0.4, lineWidth: 20.0)
    }
}
