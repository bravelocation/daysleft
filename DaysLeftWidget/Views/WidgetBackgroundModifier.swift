//
//  WidgetBackgroundModifier.swift
//  DaysLeft
//
//  Created by John Pollard on 26/05/2024.
//  Copyright © 2024 Brave Location Software. All rights reserved.
//

import SwiftUI

struct WidgetBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    let widgetDarkBackgroundGradient = LinearGradient(
        colors: [
            Color(red: 34.0/255.0, green: 34.0/255.0, blue: 37.0/255.0),
            Color(red: 44.0/255.0, green: 44.0/255.0, blue: 47.0/255.0)
        ],
        startPoint: .top,
        endPoint: .bottom)
    
    let widgetLightBackgroundGradient = LinearGradient(
        colors: [
            Color(red: 251.0/255.0, green: 251.0/255.0, blue: 255.0/255.0),
            Color(red: 241.0/255.0, green: 241.0/255.0, blue: 248.0/255.0)
        ],
        startPoint: .top,
        endPoint: .bottom)
    
    func body(content: Content) -> some View {
        content
            .containerBackground(colorScheme == .dark ? self.widgetDarkBackgroundGradient : self.widgetLightBackgroundGradient, for: .widget)
    }
}

struct WidgetAccessoryBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .containerBackground(Color.clear, for: .widget)
    }
}

extension View {
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
