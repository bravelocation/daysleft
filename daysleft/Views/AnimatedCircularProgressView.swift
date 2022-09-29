//
//  AnimatedCircularProgressView.swift
//  DaysLeft
//
//  Created by John Pollard on 28/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

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
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).delay(0.2)) {
                    self.animatedProgress = self.progress
                }
            }
        #if os(iOS)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                // If entering the foreground, reset and then update to force a re-animation
                self.animatedProgress = 0.0
                
                withAnimation(.easeInOut(duration: 1.0).delay(0.2)) {
                    self.animatedProgress = self.progress
                }
            }
        #endif
    }
}

/// Preview provider for AnimatedCircularProgressView
struct AnimatedCircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedCircularProgressView(progress: 0.4, lineWidth: 20.0)
    }
}
