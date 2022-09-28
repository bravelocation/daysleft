//
//  AnimatedPercentageDone.swift
//  DaysLeft
//
//  Created by John Pollard on 28/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

// Adapted from the post at https://stefanblos.com/posts/animating-number-changes/

import SwiftUI

struct AnimatedPercentageDone: View {
    @State private var animatedPercentageDone: Double = 0.0
    
    let percentageDone: Double
    
    var body: some View {
        Color.clear
            .animatingOverlay(for: animatedPercentageDone)
        .animation(.easeInOut(duration: 1.0).delay(0.2), value: animatedPercentageDone)
        .onAppear {
            self.animatedPercentageDone = self.percentageDone * 100
        }
    }
}

struct AnimatableNumberModifier: AnimatableModifier {
    var number: Double
    
    var animatableData: Double {
        get { number }
        set { number = newValue }
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                HStack(spacing: 0.0) {
                    Text("\(Int(number))")
                    Text("% ")
                    Text(LocalizedStringKey("Time done"))
                }
            )
    }
}

extension View {
    func animatingOverlay(for number: Double) -> some View {
        modifier(AnimatableNumberModifier(number: number))
    }
}

struct AnimatedPercentageDone_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedPercentageDone(percentageDone: 0.4)
    }
}
