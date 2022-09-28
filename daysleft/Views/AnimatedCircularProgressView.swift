//
//  AnimatedCircularProgressView.swift
//  DaysLeft
//
//  Created by John Pollard on 28/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import SwiftUI

struct AnimatedCircularProgressView: View {
    @State private var animatedProgress: Double = 0.0
    
    let progress: Double
    let lineWidth: Double
    
    var body: some View {
        CircularProgressView(progress: animatedProgress, lineWidth: lineWidth)
            .animation(.easeInOut(duration: 1.0).delay(0.2), value: animatedProgress)
            .onAppear {
                self.animatedProgress = self.progress
            }
    }
}

struct AnimatedCircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedCircularProgressView(progress: 0.4, lineWidth: 20.0)
    }
}
