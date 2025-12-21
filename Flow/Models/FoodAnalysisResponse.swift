//
//  FoodAnalysisResponse.swift
//  Flow
//
//  Created on 2025-11-05.
//

import Foundation

// MARK: - API 响应模型
struct FoodAnalysisResponse: Codable {
    let code: Int
    let message: String
    let data: FoodAnalysisData?
}

struct FoodAnalysisData: Codable {
    let foodName: String?
    let foods: [FoodItem]
    let nutrition: Nutrition
    let confidence: Double
    let isBalanced: Bool
    let nutritionSummary: String
    let highQualityProteins: [String]?
    let overallEvaluation: OverallEvaluation?
    let impact: ImpactAnalysis?
    
    enum CodingKeys: String, CodingKey {
        case foodName
        case foods
        case nutrition
        case confidence
        case isBalanced
        case nutritionSummary
        case highQualityProteins
        case overallEvaluation
        case impact
    }
}

struct FoodItem: Codable, Hashable {
    let name: String
    let cook: String?
    let kcal: Int
    let carbs: Int?
    let proteins: Int?
    let fats: Int?
    
    enum CodingKeys: String, CodingKey {
        case name
        case cook
        case kcal
        case carbs
        case proteins
        case fats
    }
}

struct Nutrition: Codable {
    let energyKcal: Int
    let proteinG: Double
    let fatG: Double
    let carbG: Double
    let fiberG: Double
    let sodiumMg: Int
    let sugarG: Double
    let satFatG: Double
    
    enum CodingKeys: String, CodingKey {
        case energyKcal = "energy_kcal"
        case proteinG = "protein_g"
        case fatG = "fat_g"
        case carbG = "carb_g"
        case fiberG = "fiber_g"
        case sodiumMg = "sodium_mg"
        case sugarG = "sugar_g"
        case satFatG = "sat_fat_g"
    }
}

struct ImpactAnalysis: Codable {
    let primaryText: String?
    let shortTerm: String
    let midTerm: String
    let longTerm: String
    let riskTags: [String]
}

struct OverallEvaluation: Codable {
    let aiIsBalanced: Bool?
    let riskLevel: String?
    let impactStrategy: String?
    let overallScore: Int?
    let tagSummaries: [String]?
}
