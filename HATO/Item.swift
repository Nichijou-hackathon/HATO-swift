//
//  Item.swift
//  HATO
//
//  Created by 濵田翔真 on 2025/06/17.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
