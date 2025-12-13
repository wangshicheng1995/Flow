//
//  APIEndpoints.swift
//  Flow
//
//  Created on 2025-12-13.
//

import Foundation

/// API 接口端点枚举
/// 统一管理所有后端接口的路径、请求方式等信息
enum APIEndpoints {
    
    // MARK: - 首页相关接口
    
    /// 首页聚合数据接口
    /// 包含：压力分数、总热量、优质蛋白、糖负荷等
    case homeDashboard(userId: String, date: String)
    
    /// 压力分数接口（保留用于其他页面）
    case stressScore
    
    // MARK: - 图片上传相关接口
    
    /// 图片上传分析接口
    case uploadImage
    
    // MARK: - 接口路径
    
    var path: String {
        switch self {
        case .homeDashboard(let userId, let date):
            return "/api/home/dashboard?userId=\(userId)&date=\(date)"
        case .stressScore:
            return "/api/health/stress-score"
        case .uploadImage:
            return "/api/image/upload"
        }
    }
    
    // MARK: - 请求方式
    
    var method: String {
        switch self {
        case .uploadImage:
            return "POST"
        default:
            return "GET"
        }
    }
    
    // MARK: - 完整 URL
    
    var url: URL? {
        URL(string: APIConfig.baseURL + path)
    }
    
    // MARK: - 是否需要认证
    
    var requiresAuth: Bool {
        switch self {
        case .stressScore:
            return false
        default:
            return true
        }
    }
}
