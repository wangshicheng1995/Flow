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
    let foodItems: [String]           // 识别出的食物列表
    let confidence: Double             // 识别置信度
    let isBalanced: Bool               // 是否营养均衡
    let nutritionSummary: String       // 营养分析摘要

    // MARK: - 辅助计算属性

    /// 将食物列表格式化为展示文本
    var foodItemsText: String {
        foodItems.joined(separator: "、")
    }
}
