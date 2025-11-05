//
//  FoodRecord.swift
//  Flow
//
//  Created on 2025-11-05.
//

import Foundation
import SwiftData

@Model
final class FoodRecord {
    var id: UUID
    var name: String
    var calories: Int
    var healthScore: Int
    var imagePath: String?
    var timestamp: Date
    var notes: String?

    init(
        id: UUID = UUID(),
        name: String,
        calories: Int,
        healthScore: Int,
        imagePath: String? = nil,
        timestamp: Date = Date(),
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.calories = calories
        self.healthScore = healthScore
        self.imagePath = imagePath
        self.timestamp = timestamp
        self.notes = notes
    }
}
