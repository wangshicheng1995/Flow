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
    let carbs: Double?      // API 返回浮点数，如 23.0
    let proteins: Double?   // API 返回浮点数，如 1.5
    let fats: Double?       // API 返回浮点数，如 0.2
    
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

// MARK: - 血糖趋势数据模型
/// 血糖趋势预测数据
struct GlucoseTrendData: Codable {
    /// 预测时间点列表（相对于用餐后的分钟数）
    let timePoints: [Int]  // e.g. [0, 15, 30, 45, 60, 90, 120]
    
    /// 对应时间点的血糖预测值 (mg/dL)
    let glucoseValues: [Double]  // e.g. [95, 120, 145, 135, 115, 100, 92]
    
    /// 血糖峰值预测
    let peakValue: Double  // e.g. 145
    
    /// 峰值出现时间（分钟）
    let peakTimeMinutes: Int  // e.g. 30
    
    /// 血糖影响评级：LOW, MEDIUM, HIGH
    let impactLevel: String
    
    /// 预计恢复到正常血糖的时间（分钟）
    let recoveryTimeMinutes: Int  // e.g. 120
    
    /// 血糖正常范围下限 (mg/dL)
    let normalRangeLow: Double  // e.g. 70
    
    /// 血糖正常范围上限 (mg/dL)
    let normalRangeHigh: Double  // e.g. 140
}

// MARK: - 饮食建议数据模型
/// 优化血糖的饮食建议
struct EatingTipsData: Codable {
    /// 主标题（简短总结）
    let title: String  // e.g. "调整进食顺序可降低血糖峰值"
    
    /// 建议列表
    let tips: [EatingTip]
    
    /// 预计改善效果描述
    let expectedImprovement: String?  // e.g. "按建议调整后，血糖峰值预计可降低 15-20%"
}

/// 单条饮食建议
struct EatingTip: Codable, Identifiable {
    var id: String { order.description }
    
    /// 建议顺序
    let order: Int
    
    /// 建议图标（SF Symbol 名称）
    let iconName: String  // e.g. "leaf.fill", "fork.knife", "timer"
    
    /// 建议标题
    let title: String  // e.g. "先吃蔬菜"
    
    /// 建议详情
    let description: String  // e.g. "先吃菠菜等蔬菜，膳食纤维可以减缓碳水吸收速度"
    
    /// 此建议对应的食物名称（可选）
    let relatedFoods: [String]?  // e.g. ["菠菜", "生菜"]
}

