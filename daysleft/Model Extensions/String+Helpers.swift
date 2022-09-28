//
//  String+Helpers.swift
//  DaysLeft
//
//  Created by John Pollard on 27/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Foundation

extension String {
    /// Caplitalises the first day of the string
    /// - Returns: Adjusted string
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    /// Caplitalises first letter of current string
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
