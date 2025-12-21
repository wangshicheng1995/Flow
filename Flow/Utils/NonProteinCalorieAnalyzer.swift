//
//  NonProteinCalorieAnalyzer.swift
//  Flow
//
//  非蛋白热量分析器
//  用于识别食材的非蛋白热量等级
//
//  公式: 非蛋白热量 = 碳水 × 4 + 脂肪 × 9
//  三级分类:
//    - 过高（红色）: > 平均值
//    - 正常（蓝色）: 平均值 × 0.5 ~ 平均值
//    - 健康（绿色）: < 平均值 × 0.5
//

import Foundation

/// 非蛋白热量等级
enum CalorieLevel {
    case high    // 过高：> 平均值 → 红色
    case normal  // 正常：平均值 × 0.5 ~ 平均值 → 蓝色
    case healthy // 健康：< 平均值 × 0.5 → 绿色
}

/// 非蛋白热量分析器
/// 根据碳水和脂肪计算非蛋白热量，将食材分为三个等级
enum NonProteinCalorieAnalyzer {
    
    /// 碳水每克产生的热量（千卡）
    private static let carbCaloriesPerGram: Double = 4.0
    
    /// 脂肪每克产生的热量（千卡）
    private static let fatCaloriesPerGram: Double = 9.0
    
    /// 计算单个食材的非蛋白热量
    /// - Parameters:
    ///   - carbs: 碳水化合物（克）
    ///   - fats: 脂肪（克）
    /// - Returns: 非蛋白热量（千卡）
    static func calculateNonProteinCalories(carbs: Int, fats: Int) -> Double {
        return Double(carbs) * carbCaloriesPerGram + Double(fats) * fatCaloriesPerGram
    }
    
    /// 分析食材列表，返回每个食材的热量等级
    /// - Parameter foods: 食材列表
    /// - Returns: 字典，key 为食材名称，value 为热量等级
    static func analyze(foods: [FoodItem]) -> [String: CalorieLevel] {
        // 食材数量 ≤ 1 时不计算，返回空字典
        guard foods.count > 1 else {
            return [:]
        }
        
        // 计算每个食材的非蛋白热量
        var nonProteinCalories: [(name: String, value: Double)] = []
        var total: Double = 0
        
        for food in foods {
            let value = calculateNonProteinCalories(
                carbs: food.carbs ?? 0,
                fats: food.fats ?? 0
            )
            nonProteinCalories.append((food.name, value))
            total += value
        }
        
        // 计算平均值和健康阈值
        let average = total / Double(foods.count)
        let healthyThreshold = average * 0.5
        
        // 判断每个食材的等级
        var result: [String: CalorieLevel] = [:]
        for item in nonProteinCalories {
            if item.value > average {
                // 过高：> 平均值
                result[item.name] = .high
            } else if item.value < healthyThreshold {
                // 健康：< 平均值 × 0.5
                result[item.name] = .healthy
            } else {
                // 正常：平均值 × 0.5 ~ 平均值
                result[item.name] = .normal
            }
        }
        
        return result
    }
    
    /// 获取单个食材的热量等级
    /// - Parameters:
    ///   - foodName: 食材名称
    ///   - foods: 完整的食材列表（用于计算平均值）
    /// - Returns: 热量等级，如果无法计算则返回 .normal
    static func getCalorieLevel(foodName: String, in foods: [FoodItem]) -> CalorieLevel {
        let analysisResult = analyze(foods: foods)
        return analysisResult[foodName] ?? .normal
    }
}
