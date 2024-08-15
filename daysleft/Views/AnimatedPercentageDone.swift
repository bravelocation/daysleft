//
//  AnimatedPercentageDone.swift
//  DaysLeft
//
//  Created by John Pollard on 28/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

// Adapted from the post at https://stefanblos.com/posts/animating-number-changes/

import SwiftUI

/// View that animates the text showing the percentage done
struct AnimatedPercentageDone: View {
    /// Animated percentage done - should be between 0.0 and 100.0
    @State private var animatedPercentageDone: Double = 0.0
    
    /// Current percentage done
    let percentageDone: Double
    
    /// Body of the view
    var body: some View {
        Color.clear
            .animatingOverlay(for: animatedPercentageDone)
        .animation(.easeInOut(duration: 1.0).delay(0.2), value: animatedPercentageDone)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).delay(0.2)) {
                self.animatedPercentageDone = self.percentageDone * 100
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .WillEnterForegroundNotification)) { _ in
            // If entering the foreground, reset and then update to force a re-animation
            self.animatedPercentageDone = 0.0
            
            withAnimation(.easeInOut(duration: 1.0).delay(0.2)) {
                self.animatedPercentageDone = self.percentageDone * 100
            }
        }
    }
}

/// Modifier to overlay the animated number value
struct AnimatableNumberModifier: AnimatableModifier {
    /// Current number
    var number: Double
    
    /// Animatable data
    var animatableData: Double {
        get { number }
    }
    
    /// Body of modifier
    /// - Parameter content: Content to modify
    /// - Returns: View
    func body(content: Content) -> some View {
        content
            .overlay(
                HStack(spacing: 0.0) {
                    Text("\(Int(number))")
                    Text("% ")
                    Text(LocalizedStringKey("Time done"))
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(Int(number))% \(NSLocalizedString("Time done", comment: ""))")
            )
    }
}

extension View {
    /// View extension for AnimatableNumberModifier
    /// - Parameter number: Number to animate to
    /// - Returns: View
    func animatingOverlay(for number: Double) -> some View {
        modifier(AnimatableNumberModifier(number: number))
    }
}

/// Preview provider for AnimatedPercentageDone
struct AnimatedPercentageDone_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedPercentageDone(percentageDone: 0.4)
    }
}
