//
//  Item.swift
//  Flow
//
//  Created by Echo Wang on 2025/11/5.
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
