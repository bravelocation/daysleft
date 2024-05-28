//
//  WidgetBackgroundModifier.swift
//  DaysLeft
//
//  Created by John Pollard on 26/05/2024.
//  Copyright © 2024 Brave Location Software. All rights reserved.
//

import SwiftUI

struct WidgetBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, macOS 14.0, watchOS 10.0, *) {
            content
                .containerBackground(Color("WidgetBackground"), for: .widget)
        } else {
            content
        }
    }
}

struct WidgetAccessoryBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, macOS 14.0, watchOS 10.0, *) {
            content
                .containerBackground(Color.clear, for: .widget)
        } else {
            content
        }
    }
}

extension View {
    @warn_unqualified_access
    func preferWidgetBackground(accessoryWidget: Bool = false) -> some View {
        Group {
            if accessoryWidget {
                modifier(WidgetAccessoryBackgroundModifier())
            } else {
                modifier(WidgetBackgroundModifier())
            }
        }
    }
}

