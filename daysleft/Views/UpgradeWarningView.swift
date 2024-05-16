//
//  UpgradeWarningView.swift
//  DaysLeft
//
//  Created by John Pollard on 16/05/2024.
//  Copyright © 2024 Brave Location Software. All rights reserved.
//

import SwiftUI

/// Main view of app
struct UpgradeWarningView: View {
    // Remote settings
    @ObservedObject var remoteConfig: RemoteConfigManager = RemoteConfigManager.shared
    
    /// Body of view
    var body: some View {
        if remoteConfig.showMessage {
            VStack {
                HStack(alignment: .top) {
                    Image(systemName: "info.circle")
                        .font(.headline)
                    Text(remoteConfig.message ?? "")
                }
                .foregroundColor(Color.red)
                
                Button("Open in App Store") {
                    remoteConfig.openInAppStore()
                }
                .buttonStyle(.borderedProminent)
            }
        } else {
            EmptyView()
        }
    }
}
