//
//  Item.swift
//  CuttDB
//
//  Created by SHIJIAN on 2025/5/30.
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
