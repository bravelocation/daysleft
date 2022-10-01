//
//  TextFieldClearButton.swift
//  DaysLeft
//
//  Created by John Pollard on 01/10/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

// Adapted from https://sanzaru84.medium.com/swiftui-how-to-add-a-clear-button-to-a-textfield-9323c48ba61c

import SwiftUI

/// Modifier to add a clear button to a TextField
struct TextFieldClearButton: ViewModifier {
    /// Text to bind to that will be cleared
    @Binding var text: String
    
    func body(content: Content) -> some View {
        HStack {
            content
            
            if !text.isEmpty {
                Button(
                    action: { self.text = "" },
                    label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                )
            }
        }
    }
}

extension View {
    /// View extension for TextFieldClearButton
    /// - Parameter text: Binding to text to clear
    /// - Returns: View
    func addClearButton(for text: Binding<String>) -> some View {
        modifier(TextFieldClearButton(text: text))
    }
}
