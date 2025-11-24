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
    let foods: [FoodItem]
    let nutrition: Nutrition
    let confidence: Double
    let isBalanced: Bool
    let nutritionSummary: String
    let impactAnalysis: ImpactAnalysis
    
    enum CodingKeys: String, CodingKey {
        case foods
        case nutrition
        case confidence
        case isBalanced
        case nutritionSummary
        case impactAnalysis = "impact_analysis"
    }
}

struct FoodItem: Codable, Hashable {
    let name: String
    let amountG: Int
    let cook: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case amountG = "amount_g"
        case cook
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
    let shortTerm: String
    let midTerm: String
    let longTerm: String
    let riskTags: [String]
    
    enum CodingKeys: String, CodingKey {
        case shortTerm = "short_term"
        case midTerm = "mid_term"
        case longTerm = "long_term"
        case riskTags = "risk_tags"
    }
}

