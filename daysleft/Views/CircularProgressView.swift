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

    
    /// Body of view
    var body: some View {
        GeometryReader { geo in
            let effectiveLineWidth = geo.size.height / 3.0

            ZStack {
                Circle()
                    .stroke(
                        Color("LightAppColor"),
                        style: StrokeStyle(lineWidth: effectiveLineWidth)
                    )
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color("MainAppColor"),
                        style: StrokeStyle(lineWidth: effectiveLineWidth)
                    )
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        // ensure the control stays square when laid out
        .aspectRatio(1, contentMode: .fit)
    }
}

/// Preview provider for CircularProgressView
struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressView(progress: 0.4)
    }
}
