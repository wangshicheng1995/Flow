//
//  SummaryEndpoints.swift
//  Flow
//
//  Summary（概览）模块的 API 端点定义
//

import Foundation

/// Summary 模块 API 端点
enum SummaryEndpoints {
    
    /// 每日卡路里数据接口
    /// - Parameter userId: 用户 ID
    /// - 返回最近 7 天的每日卡路里数据
    case dailyCalories(userId: String)
    
    // MARK: - 接口路径
    
    var path: String {
        switch self {
        case .dailyCalories(let userId):
            return "/api/summary/calories/daily?userId=\(userId)"
        }
    }
    
    // MARK: - 请求方式
    
    var method: String {
        switch self {
        case .dailyCalories:
            return "GET"
        }
    }
    
    // MARK: - 完整 URL
    
    var url: URL? {
        URL(string: APIConfig.baseURL + path)
    }
}
