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
    
    @ObservedObject var model = WatchDaysLeftData()
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                Text(self.model.currentTitle)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                ProgressControl(foregroundColor: Color("LightAppColor"),
                                backgroundColor: Color("MainAppColor"),
                                progress: self.model.percentageDone,
                                width: 20.0)
                    .frame(width: self.progressDimensions(geo.size),
                           height: self.progressDimensions(geo.size))
                Text(self.model.currentPercentageLeft).font(.footnote)
            }
        }
    }
    
    func progressDimensions(_ screenSize: CGSize) -> CGFloat {
        if (screenSize.width > screenSize.height) {
            return screenSize.height - 80
        } else {
            return screenSize.width - 60
        }
    }
}

struct WatchView_Previews: PreviewProvider {
    static var previews: some View {
        WatchView()
    }
}
