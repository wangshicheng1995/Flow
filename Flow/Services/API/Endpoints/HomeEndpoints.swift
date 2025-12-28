//
//  HomeEndpoints.swift
//  Flow
//
//  首页（Home）模块的 API 端点定义
//

import Foundation

/// 首页模块 API 端点
enum HomeEndpoints {
    
    /// 首页仪表盘聚合数据
    /// - Parameters:
    ///   - userId: 用户 ID
    ///   - date: 日期（yyyy-MM-dd 格式）
    case dashboard(userId: String, date: String)
    
    // MARK: - 接口路径
    
    var path: String {
        switch self {
        case .dashboard(let userId, let date):
            return "/api/home/dashboard?userId=\(userId)&date=\(date)"
        }
    }
    
    // MARK: - 请求方式
    
    var method: String {
        switch self {
        case .dashboard:
            return "GET"
        }
    }
    
    // MARK: - 完整 URL
    
    var url: URL? {
        URL(string: APIConfig.baseURL + path)
    }
}
