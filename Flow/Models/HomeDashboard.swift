//
//  HomeDashboard.swift
//  Flow
//
//  Created on 2025-12-13.
//

import Foundation

/// 首页仪表盘聚合数据模型
/// 对应后端 /home/dashboard 接口返回的数据结构
struct HomeDashboard: Codable {
    /// 用户 ID
    let userId: String?
    
    /// 日期
    let date: String?
    
    /// 压力/健康评分（0-100）
    let stressScore: Int?
    
    /// 今日总热量（卡路里）
    let totalCalories: Int?
    
    /// 今日餐食记录数量
    let mealCount: Int?
    
    /// 优质蛋白列表（今日摄入的优质蛋白种类）
    let highQualityProteins: [String]?
    
    // MARK: - 未来扩展字段（后端暂未实现）
    
    /// 糖负荷指数
    let glycemicLoad: Double?
}

/// 首页仪表盘 API 响应包装
struct HomeDashboardResponse: Codable {
    let code: Int
    let message: String
    let data: HomeDashboard?
}
