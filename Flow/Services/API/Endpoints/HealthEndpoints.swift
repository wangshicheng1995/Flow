//
//  HealthEndpoints.swift
//  Flow
//
//  Health（健康）模块的 API 端点定义
//

import Foundation

/// Health 模块 API 端点
enum HealthEndpoints {
    
    /// 压力分数接口
    case stressScore
    
    // MARK: - 接口路径
    
    var path: String {
        switch self {
        case .stressScore:
            return "/api/health/stress-score"
        }
    }
    
    // MARK: - 请求方式
    
    var method: String {
        switch self {
        case .stressScore:
            return "GET"
        }
    }
    
    // MARK: - 完整 URL
    
    var url: URL? {
        URL(string: APIConfig.baseURL + path)
    }
}
