//
//  AnimatedCircularProgressView.swift
//  DaysLeft
//
//  Created by John Pollard on 28/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import SwiftUI

/// View that animates a circular progress view
struct AnimatedCircularProgressView: View {
    /// Animation progress value-  should be bewteen 0.0 and 1.0
    @State private var animatedProgress: Double = 0.0
    
    /// Progress value - should be bewteen 0.0 and 1.0
    let progress: Double
    
    /// Width of the lines of the prgress view
    let lineWidth: Double
    
    /// Body of view
    var body: some View {
        CircularProgressView(progress: animatedProgress, lineWidth: lineWidth)
            .animation(.easeInOut(duration: 1.0).delay(0.2), value: animatedProgress)
            .onAppear {
                self.animatedProgress = self.progress
            }
    }
}

/// Preview provider for AnimatedCircularProgressView
struct AnimatedCircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedCircularProgressView(progress: 0.4, lineWidth: 20.0)
    }
}
