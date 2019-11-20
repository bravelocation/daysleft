//
//  WatchView.swift
//  daysleft WatchKit Extension
//
//  Created by John Pollard on 13/11/2019.
//  Copyright © 2019 Brave Location Software. All rights reserved.
//

import Foundation
import SwiftUI

struct WatchView: View {
    
    @ObservedObject var model: WatchDaysLeftData
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                Text(self.model.currentTitle)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                Text(self.model.currentSubTitle)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                ProgressControl(foregroundColor: Color("LightAppColor"),
                                backgroundColor: Color("MainAppColor"),
                                model: self.model,
                                lineWidth: 20.0,
                                frameSize: self.progressDimensions(geo.size))
                    .padding()
                Text(self.model.currentPercentageLeft).font(.footnote)
            }
        }
    }
    
    func progressDimensions(_ screenSize: CGSize) -> CGFloat {
        if (screenSize.width > screenSize.height) {
            return screenSize.height - 100
        } else {
            return screenSize.width - 100
        }
    }
}

struct WatchView_Previews: PreviewProvider {
    static var previews: some View {
        WatchView(model: WatchDaysLeftData())
    }
}
